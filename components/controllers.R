library(htmltools)

controllers <- function(){
    div(
        class = "controls",
        tags$h3("Controllers: "),
        tags$select(
            onChange = "handleSortChange(event)",
            tags$option(value = "", selected = TRUE, "--- Order by ---"),
            tags$option(value = "most-recent", "Most recent"),
            tags$option(value = "oldest", "Oldest"),
            tags$option(value = "alphabetical", "Alphabetical"),
            tags$option(value = "reverse-alphabetical", "Reverse alphabetical")
        ),
        tags$select(
            onChange = "handleFilterChange(event)",
            tags$option(value = "all", selected = TRUE, "--- Filter ---"),
            tags$option(value = "Loot", "Loot"),
        )
    )
}