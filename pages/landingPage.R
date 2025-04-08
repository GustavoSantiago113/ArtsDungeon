library(htmltools)
source("components/cards.R")
source("components/controllers.R")

gallery <- function(data){
    
    cards_list <- lapply(1:nrow(data), function(i) {
    
    name <- data[i, "Name"]
    brandURL <- data[i, "BrandURL"]
    brandLogo <- data[i, "BrandLogo"]
    image_url <- data[i, "ImageURL"]
    
    cards(name, brandURL, brandLogo, image_url)
  })
}

landingPage <- function(data){
    div(
        controllers(),
        div(
            class = "gallery",
            gallery(data)
        )
    )
}