library(shiny)
library(shinyWidgets)
source("components/header.R")
source("components/footer.R")
source("pages/landingPage.R")

minisData <- read.csv("data.csv")

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
    landingPage(minisData),
  ),
  
  ## 3. Inserting Footer ----
  footer(),
)

# Server ----
server <- function(input, output, session) {
  
}

shinyApp(ui, server)