library(htmltools)

header <- function(){
    div(
        tags$header(
            h1(
                "Art's Dungeon"
            ),
            div(
                class = "icons",
                div(
                    class="dropdown",
                    div(
                        class = "dropbtn",
                        tags$img(
                            class = "icon",
                            src = "dollar.svg",
                            alt = ""
                        )
                    ),
                    div(
                        class = "dropdown-content",
                        tags$span("Tip the artist - CashApp: $GustavoSantiago113")
                    )
                ),
                div(
                    class="dropdown",
                    div(
                        class = "dropbtn",
                        tags$img(
                            class = "icon",
                            src = "mail.svg",
                            alt = ""
                        )
                    ),
                    div(
                        class = "dropdown-content",
                        tags$span("Contact: gnocerasantiago@gmail.com")
                    )
                )
            )
        )
    )
}