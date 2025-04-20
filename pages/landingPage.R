library(htmltools)
source("components/cards.R")

gallery <- function(data){
    
    cards_list <- lapply(1:nrow(data), function(i) {
    
    name <- data[i, "Name"]
    brandURL <- data[i, "BrandURL"]
    brandLogo <- data[i, "BrandLogo"]
    image_url <- data[i, "ImageURL"]
    id <- data[i, "id"]
    
    
    cards(name, brandURL, brandLogo, image_url, id)
  })
}

landingPage <- function(data){
    
    div(
        class = "gallery",
        gallery(data)
    )

}