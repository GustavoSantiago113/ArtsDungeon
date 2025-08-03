library(shiny)
library(shinyWidgets)
library(shiny.router)
library(dplyr)
library(shinyjs)
library(shinyFeedback)
library(emayili)
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
        "MZ4250" = "MZ4250"
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
    class="min-h-screen flex flex-col items-center py-8 px-4 sm:px-6 lg:px-8",
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

  current_id <- reactive({
    params <- get_query_param()
    id <- params$id
    return(id)
  })

  # Handle 3D view button click
  observeEvent(input[[paste0("btn_3d_", current_id())]], {
    identifier <- current_id()
    product_data <- minis_data %>% filter(id == identifier)
    viewer_id <- paste0("viewer-", identifier)
    image_view_id <- paste0("image-view-", identifier)
    loader_id <- paste0("loader-", identifier)

    # Hide image view and show loader
    shinyjs::hide(image_view_id)
    shinyjs::hide(viewer_id)
    shinyjs::show(loader_id)

    # Load the 3D model
    shinyjs::delay(100, {
      # Load the 3D model
      session$sendCustomMessage("load_pointcloud", list(
        id = viewer_id,
        loader_id = loader_id,
        url = paste0("Reconstructions/", product_data$Name, ".ply"),
        type = "ply"
      ))
    })
  })

  observeEvent(input[[paste0("btn_image_", current_id())]], {
    identifier <- current_id()
    viewer_id <- paste0("viewer-", identifier)
    image_view_id <- paste0("image-view-", identifier)

    # Hide 3D viewer and show image view
    shinyjs::hide(viewer_id)
    shinyjs::show(image_view_id)
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