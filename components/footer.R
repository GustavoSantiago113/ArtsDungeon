library(htmltools)

footer <- function(){
    tags$footer(
        div(
            class = "footer",
            tags$a(
                href = "https://github.com/GustavoSantiago113/MiniAid",
                target = "_blank",
                class = "footer-icon-link",
                tags$img(
                    src = "github.png",
                    class = "footer-icon"
                ),
            ),
            tags$span(
                class = "footer-text",
                "Developed by: Gustavo N. Santiago",
                tags$br(),
                "Under the MIT License"
            ),
            tags$a(
                href = "https://gustavosantiago.shinyapps.io/WebResume/",
                target = "_blank",
                class = "footer-icon-link",
                tags$img(
                    src = "webResume.png",
                    class = "footer-icon"
                ),
            ),
        )
    )
}