library(htmltools)
library(tidyverse)
library(shiny.router)

cards <- function(name, brandURL, brandLogo, miniId){
    div(
        class = "card",
        div(
            class = "card-header",
            tags$a(
                href = brandURL,
                tags$img(
                    src = paste0("Logos/", brandLogo, sep=""),
                    alt = "",
                    class = "source-icon"
                )
            )
        ),
        tags$img(
            src = paste0("Images/", name, ".png", sep=""),
            alt= "",
            class="card-image"
        ),
        tags$a(
            href = route_link(paste("mini?id=", miniId, sep="")),
            tags$p(
                class="card-title",
                name
            )
        )
    )
}