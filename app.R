library(shiny)
library(shinyWidgets)
library(shiny.router)
library(dplyr)
source("components/header.R")
source("components/footer.R")
source("pages/landingPage.R")
source("pages/individual.R")

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
  
  ## Inserting CSS ----
  tags$head(
    tags$link(
      rel  = "stylesheet",
      type = "text/css",
      href = "styles.css")
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
        # Get the current product ID
        identifier <- current_id()
        
        # Get the data for this product
        product_data <- minisData %>% filter(id == identifier)
        
        # Create the 3D viewer element
        # This uses the threejs package, but you could use any 3D visualization approach
        model_html <- tags$div(
            class = "model-container",
            tags$iframe(
                src = paste0("https://example.com/3d-viewer?model=", product_data$ModelURL),
                frameborder = "0",
                style = "width: 100%; height: 100%;"
            )
        )
        
        # Insert the 3D model into the container
        removeUI(selector = paste0("#image-container-", identifier, " > *"))
        insertUI(
            selector = paste0("#image-container-", identifier),
            where = "beforeEnd",
            ui = model_html
        )
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

}

shinyApp(ui, server)