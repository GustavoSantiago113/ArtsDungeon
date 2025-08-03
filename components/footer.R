library(htmltools)

footer <- function(){
    tags$footer(
        class="w-full mt-12 py-6 text-gray-400 text-center rounded-lg shadow-inner",
        style = "background-color: #297373;",
        div(
            class="flex flex-col sm:flex-row items-center justify-center sm:justify-between gap-4 px-4",
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
                class="footer-text text-sm sm:text-base",
                "© 2025 Gustavo N. Santiago. All rights reserved",
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