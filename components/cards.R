library(htmltools)

cards <- function(name, brandURL, brandLogo, imageURL){
    div(
        class = "card",
        div(
            class = "card-header",
            tags$a(
                href = brandURL,
                tags$img(
                    src = paste0("https://lh3.googleusercontent.com/d/", brandLogo, sep=""),
                    alt = "",
                    class = "source-icon"
                )
            )
        ),
        tags$img(
            src = paste0("https://lh3.googleusercontent.com/d/", imageURL, sep=""),
            alt= "",
            class="card-image"
        ),
        tags$p(
            class="card-title",
            name
        )
    )
}