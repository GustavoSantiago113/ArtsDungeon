library(shiny)
library(shinyWidgets)
library(shiny.router)
library(dplyr)
library(shinyjs)
library(shinyFeedback)
library(emayili)
library(googledrive)
library(httr)
source("components/header.R")
source("components/footer.R")
source("pages/landingPage.R")
source("pages/individual.R")
source("components/requestModal.R")

home <- tags$main(
  div(
    class = "controls",
    selectInput(
      inputId = "sort_select",
      label = NULL,
      choices = list(
        "Order by" = "",
        "Most recent" = "most-recent",
        "Oldest" = "oldest",
        "Alphabetical" = "alphabetical",
        "Reverse alphabetical" = "reverse-alphabetical"
      ),
      selected = "most-recent"
    ),
    selectInput(
      inputId = "filter_select",
      label = NULL,
      choices = list(
        "Filter by" = "all",
        "Loot" = "Loot",
        "MZ4250" = "MZ4250",
        "StromCrow13" = "StromCrow13"
      ),
      selected = "all"
    )
  ),
  uiOutput("LandingPage")
)

ui <- fluidPage(

  ## Setting to use JavaScript ----
  useShinyjs(),
  shinyFeedback::useShinyFeedback(),

  ## Inserting CSS ----
  tags$head(
    tags$meta(charset="UTF-8"),
    tags$meta(name="viewport", content="width=device-width, initial-scale=1.0"),
    tags$title("Art's Dungeon"),
    tags$link(
              rel = "stylesheet",
              type = "text/css",
              href = "styles.css"),
    tags$script(src = "https://unpkg.com/vtk.js"),
    tags$script(src = "viewer.js"),
    tags$script(src = "https://cdn.tailwindcss.com")
  ),

  tags$body(
    ## 1. Inserting Header ----
    header(),

    ## 2. Inserting Content ----
    router_ui(
      route("/", home),
      route("mini", uiOutput("IndividualPage"))
    ),

    ## 3. Inserting Footer ----
    footer()
  )

)

# Server ----
server <- function(input, output, session) { # nolint

  router_server()

  minis_data <- read.csv("data.csv")

  # Create a reactive value to store processed data
  processed_data <- reactiveVal(minis_data)

  # Observe changes in both inputs
  observeEvent({
    input$sort_select
    input$filter_select
  }, {

    data <- minis_data

    # Apply filtering
    if (!is.null(input$filter_select) && input$filter_select != "all") {
      data <- data[data$BrandName == input$filter_select, ]
    }

    # Apply sorting only if we have data
    if (nrow(data) > 0) {
      if (input$sort_select == "most-recent") {
        data <- data[order(as.Date(data$PaintDate, "%Y/%m/%d"),
                           decreasing = TRUE), ]
      } else if (input$sort_select == "oldest") {
        data <- data[order(as.Date(data$PaintDate, "%Y/%m/%d"),
                           decreasing = FALSE), ]
      } else if (input$sort_select == "alphabetical") {
        data <- data[order(data$Name), ]
      } else if (input$sort_select == "reverse-alphabetical") {
        data <- data[order(data$Name, decreasing = TRUE), ]
      }
    }

    # Update the reactive value
    processed_data(data)
  }, ignoreNULL = FALSE, ignoreInit = FALSE)

  # Render the display of minis
  output$LandingPage <- renderUI({
    data <- processed_data()

    if (is.null(data) || nrow(data) == 0) {
      return(div(class = "no-results", "No miniatures match your filters"))
    }

    landingPage(data) # nolint
  })

  output$IndividualPage <- renderUI({
    params <- get_query_param()
    individual_page(params$id, minis_data) # nolint
  })

  # No longer need to manage downloaded_plys this way, but the directory path is key
  session$userData$session_dir <- file.path("www", "session-plys", session$token)

  # Ensure the www directory and the session-specific subdirectory exist
  if (!dir.exists("www")) dir.create("www")
  dir.create(session$userData$session_dir, recursive = TRUE, showWarnings = FALSE)

  observe({
      params <- get_query_param()
      selected_id <- params$id
      req(selected_id)
      trigger_name <- paste0("trigger_viewer_", selected_id)
      req(input[[trigger_name]])

      dataIndividual <- minis_data[minis_data$id == as.numeric(selected_id), , drop = FALSE]
      raw_val <- as.character(if (nrow(dataIndividual) >= 1) dataIndividual$ReconstructionURL[1] else NA_character_)
      ply_file_id <- if (length(raw_val) >= 1) raw_val[1] else NA_character_
      message("PLY file id candidate: ", ply_file_id)

      # Use a simple, unique filename
      ply_filename <- paste0(selected_id, ".ply")
      
      # Define the full path inside the session-specific 'www' subdirectory
      ply_path <- file.path(session$userData$session_dir, ply_filename)

      tryCatch({
          if (is.na(ply_file_id) || ply_file_id == "") stop("No valid PLY file id found")

          # --- DOWNLOAD LOGIC (This part is fine and remains unchanged) ---
          public_url <- paste0("https://drive.google.com/uc?export=download&id=", ply_file_id)
          message("Trying public download: ", public_url)
          res <- tryCatch(
              httr::GET(public_url, httr::write_disk(ply_path, overwrite = TRUE), httr::timeout(60)),
              error = function(e) { NULL }
          )
          need_api_download <- TRUE
          if (!is.null(res) && httr::status_code(res) >= 200 && httr::status_code(res) < 400 && file.exists(ply_path) && file.size(ply_path) > 0) {
              need_api_download <- FALSE
              message("Public download succeeded: ", ply_path)
          } else {
              message("Public download failed or status: ", ifelse(is.null(res), "no response", httr::status_code(res)))
          }
          if (need_api_download) {
              # ... your googledrive::drive_download logic ...
              googledrive::drive_download(
                file = googledrive::as_id(ply_file_id),
                path = ply_path,
                overwrite = TRUE
              )
              message("API download succeeded: ", ply_path)
          }
          # --- END DOWNLOAD LOGIC ---

          if (!file.exists(ply_path)) stop("Download failed; file missing at path")
          
          # The URL is now the path relative to the 'www' directory
          resource_url <- file.path("session-plys", session$token, ply_filename)
          
          session$sendCustomMessage(
              type = "load_pointcloud",
              message = list(
                  id = paste0("viewer-", selected_id),
                  loader_id = paste0("loader-", selected_id),
                  url = resource_url # Send the correct public URL
              )
          )
      }, error = function(e) {
          message("Error downloading PLY: ", e$message)
          session$sendCustomMessage(
              type = "load_pointcloud",
              message = list(
                  id = paste0("viewer-", selected_id),
                  loader_id = paste0("loader-", selected_id),
                  url = NULL,
                  error = e$message
              )
          )
      })
  })

  # Clean up the session directory when the session ends
  session$onSessionEnded(function() {
      session_dir <- session$userData$session_dir
      message("Session ended. Cleaning up directory: ", session_dir)
      if (dir.exists(session_dir)) {
          unlink(session_dir, recursive = TRUE, force = TRUE)
      }
  })

  current_id <- reactive({
    params <- get_query_param()
    id <- params$id
    return(id)
  })

  observeEvent(input$want_one_button, {request_one()}) # nolint
  
  observe({
      if (!is.null(input$name) && input$name != "" &&
            !is.null(input$email) && input$email != "" &&
            !is.null(input$message) && input$message != "" &&
            !is.null(input$country) && input$country != "") {
      enable("sendEmail")
    } else {
      disable("sendEmail")
    }
  })

  observeEvent(input$sendEmail, {

    # Disabling button
    disable("sendEmail")

    # Inform that the user is being created
    showNotification("Email being sent", type = "message")

    tryCatch({
      print(paste0(input$name, ", from ",
                   input$country, " with email ", input$email,
                   " sent the following message: ",
                   input$message))
      try({
        # Creating the email
        email <- envelope(
          to = "gnocerasantiago@gmail.com",
          from = "gnocerasantiago@gmail.com",
          subject = paste0("Mini with id=", current_id(), " wanted"),
          text = paste0(input$name, ", from ", input$country,
                        " with email ", input$email,
                        " sent the following message: ",
                        input$message)
        )

        # Creating the SMTP server object
        smtp <- gmail(
          username = Sys.getenv("GMAIL_USERNAME"),
          password = Sys.getenv("GMAIL_PASSWORD")
        )

        # Sending the email
        smtp(email, verbose = TRUE)
      }, silent = TRUE)

    }, error = function(e) {

      # Inform that the user was created
      showNotification("Something went wrong, try again later", type = "error")
      # Close the modal
      removeModal()

    }, finally = {

      # Inform that the user was created
      showNotification("Email sent", type = "default")
      # Close the modal
      removeModal()

    })

  })

}

shinyApp(ui, server)