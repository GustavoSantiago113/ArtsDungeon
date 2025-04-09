library(shiny)
library(shinyWidgets)
source("components/header.R")
source("components/footer.R")
source("pages/landingPage.R", local = TRUE)

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
  div(
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
        uiOutput("LandingPage"),
  ),
  
  ## 3. Inserting Footer ----
  footer(),
  
)

# Server ----
server <- function(input, output, session) {
  
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

}

shinyApp(ui, server)