library(htmltools)
source("components/cards.R")

gallery <- function(data){
    
    cards_list <- lapply(1:nrow(data), function(i) {
    
        name <- data[i, "Name"]
        id <- data[i, "id"]
        coverURL <- data[i, "CoverURL"]
        
        cards(name, id, coverURL)
    })
}

landingPage <- function(data){
    
    div(
        class="min-h-screen flex flex-col items-center py-8 px-4 sm:px-6 lg:px-8",
        div(
            class="w-full flex-grow",
            div(
                class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-8",
                gallery(data)
            )
        )
    )
    

}