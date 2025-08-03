library(htmltools)
library(tidyverse)
library(shiny.router)

cards <- function(name, miniId, coverURL){
    div(
        class = 'miniature-card block bg-gray-800 rounded-xl shadow-md overflow-hidden cursor-pointer hover:shadow-lg hover:scale-105 transform transition-all duration-300 ease-in-out',
        tags$img(
            src = paste0("https://lh3.googleusercontent.com/d/", coverURL, sep=""),
            alt= "",
            class="w-full object-contain rounded-t-xl"
        ),
        div(
            class="p-4 flex-grow flex flex-col justify-center",
            h3(class="text-xl font-semibold text-gray-200 truncate", name),
            p(class="text-sm text-gray-400 mt-1", "Click for details")
        )
    ) %>% tags$a(
            href = route_link(paste("mini?id=", miniId, sep="")))
}