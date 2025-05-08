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

home <- div(
  div(
    class = "controls",
    tags$h3("Controllers: "),
    selectInput(
        inputId = "sort_select",
        label = NULL,
        choices = list(
            "--- Order by ---" = "",
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
            "--- Filter ---" = "all",
            "Loot" = "Loot"
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
    tags$link(
      rel  = "stylesheet",
      type = "text/css",
      href = "styles.css"),
      tags$script(src = "https://unpkg.com/vtk.js"),
      tags$script(src = "viewer.js")
  ),
  
  ## 1. Inserting Header ----
  header(),
  
  ## 2. Inserting Content ----
  router_ui(
    route("/", home),
    route("mini", uiOutput("IndividualPage"))
  ),
  
  ## 3. Inserting Footer ----
  footer(),
  
)

# Server ----
server <- function(input, output, session) {
  
  router_server()

  minisData <- read.csv("data.csv")
  
  # Create a reactive value to store processed data
  processedData <- reactiveVal(minisData)
  
  # Observe changes in both inputs
  observeEvent({
    input$sort_select
    input$filter_select
  }, {
    
    data <- minisData
    
    # Apply filtering
    if (!is.null(input$filter_select) && input$filter_select != "all") {
      data <- data[data$BrandName == input$filter_select, ]
    }
    
    # Apply sorting only if we have data
    if (nrow(data) > 0) {
      if (input$sort_select == "most-recent") {
        data <- data[order(as.Date(data$PaintDate), decreasing = TRUE), ]
      } else if (input$sort_select == "oldest") {
        data <- data[order(as.Date(data$PaintDate), decreasing = FALSE), ]
      } else if (input$sort_select == "alphabetical") {
        data <- data[order(data$Name), ]
      } else if (input$sort_select == "reverse-alphabetical") {
        data <- data[order(data$Name, decreasing = TRUE), ]
      }
    }
    
    # Update the reactive value
    processedData(data)
  }, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  # Render the display of minis
  output$LandingPage <- renderUI({
    data <- processedData()
    
    if (is.null(data) || nrow(data) == 0) {
      return(div(class = "no-results", "No miniatures match your filters"))
    }
    
    landingPage(data)
  })

  output$IndividualPage <- renderUI({
    params <- get_query_param()
    individual_page(params$id, minisData)
  })

  current_id <- reactive({
    params <- get_query_param()
    id <- params$id
    return(id)
  })

  observeEvent(input[[paste0("btn_3d_", current_id())]], {
      identifier <- current_id()
      product_data <- minisData %>% filter(id == identifier)
      viewer_id <- paste0("viewer-", identifier)

      model_html <- tags$div(
          class = "model-container",
          id = viewer_id,
          style = "width: 100%; height: 50vh;"
      )

      # Insert the 3D model container
      removeUI(selector = paste0("#image-container-", identifier, " > *"))
      insertUI(
          selector = paste0("#image-container-", identifier),
          where = "beforeEnd",
          ui = model_html
      )

      # Delay the message just enough for the DOM to be updated
      later::later(function() {
          session$sendCustomMessage("load_pointcloud", list(
              id = viewer_id,
              url = paste0("point_clouds/", product_data$Name, ".ply"),
              type = "ply"
          ))
      }, delay = 0.1)  # 100 milliseconds
  })
    
    # Handle image view button click (to go back to the image)
    observeEvent(input[[paste0("btn_image_", current_id())]], {
        # Get the current product ID
        identifier <- current_id()

        # Get the data for this product
        product_data <- minisData %>% filter(id == identifier)

        # Create the image element
        image_html <- tags$div(
            img(
                id = "product-main-image",
                class = "product-image",
                src = paste0("https://lh3.googleusercontent.com/d/", product_data$ImageURL),
                alt = "Product Image"
            )
        )
        
        # Insert the image into the container
        removeUI(selector = paste0("#image-container-", identifier, " > *"))
        insertUI(
            selector = paste0("#image-container-", identifier),
            where = "beforeEnd",
            ui = image_html
        )
    })

    observeEvent(input$want_one_button, {request_one()})
    observe({
      if(!is.null(input$name) && input$name !="" && !is.null(input$email) && input$email !="" && !is.null(input$message) && input$message!="" && !is.null(input$country) && input$country !=""){
        enable("sendEmail")
      }
      else{
        disable("sendEmail")
      }
    })

    observeEvent(input$sendEmail, {
    
      # Disabling button
      disable("sendEmail")
      
      # Inform that the user is being created
      showNotification("Email being sent", type = "message")
      
      tryCatch({
        print(paste0(input$name,", from ", input$country," with email ", input$email, " sent the following message: ", input$message))
        try({
          # Creating the email
          email <- envelope(
            to = "gnocerasantiago@gmail.com",
            from = "gnocerasantiago@gmail.com",
            subject = paste0("Mini with id=", current_id(), " wanted"),
            text = paste0(input$name,", from ", input$country," with email ", input$email, " sent the following message: ", input$message)
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