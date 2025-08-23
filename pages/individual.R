library(shiny)
library(shiny.router)
library(dplyr)

individual_page <- function(identifier, data) {

    dataIndividual <- data %>% filter(id == identifier)

    image_ids <- unlist(strsplit(as.character(dataIndividual$ImagesURL), ";"))
    image_urls <- paste0("https://lh3.googleusercontent.com/d/", image_ids)

    viewer_id <- paste0("viewer-", identifier)
    loader_id <- paste0("loader-", identifier)

    ui <- div(
        class="w-full flex-grow bg-gray-800 p-8 rounded-xl shadow-lg",
        div(
            class = "return-button-container",
            tags$a(
                href = route_link("/"),
                class = "return-button",
                "← Return"
            )
        ),
        div(
            class = "disclaimer-box",
            p("Disclaimer: By the user agreement of the studio, I cannot sell this miniature. However, If you want a similar one painted by me, please reach out so we can talk! I will have to charge for shipping and production costs.")
        ),

        div(
            class="flex flex-col lg:flex-row gap-8",
            div(
                class="flex-1 flex flex-col items-center gap-6",
                tags$h2(class="text-3xl font-bold text-white mb-4", dataIndividual$Name),
                # Loader shown until JS replaces it with VTK canvas
                div(id = loader_id, class = "loader-container", style = "height:400px; display:flex; align-items:center; justify-content:center;",
                    div(class = "loader", "Loading 3D model...")
                ),
                # Viewer container (hidden until viewer.js shows it)
                div(id = viewer_id, class = "reconstruction-container", style = "height:400px; display:none; width:100%;"),

                tags$div(
                    class = "w-full bg-gray-700 p-4 rounded-lg shadow-md flex items-center gap-4",
                    tags$img(
                        id = "brand-logo",
                        src = paste0("Logos/", dataIndividual$BrandLogo),
                        alt = "Brand Logo",
                        class = "w-16 h-16 rounded-full object-contain border-2 border-gray-500"
                    ),
                    tags$div(
                        tags$p(
                            class = "text-lg font-semibold text-gray-200",
                            "Brand: ",
                            tags$span(
                                id = "brand-name",
                                dataIndividual$BrandName
                            )
                        ),
                        tags$a(
                            id = "brand-url",
                            href = dataIndividual$BrandURL,
                            target = "_blank",
                            class = "text-blue-400 hover:text-blue-300 text-sm",
                            "Visit Brand Website"
                        )
                    )
                ),
                tags$p(class = "text-md text-gray-400", "Painted On: ", tags$span(id = "paint-date", class = "font-semibold text-gray-300", dataIndividual$PaintDate))
            ),
            div(
                class="flex-1 flex flex-col gap-6",
                tags$h3(class="text-2xl font-bold text-white mb-2", "Additional Views"),
                div(class="grid grid-cols-1 sm:grid-cols-2 gap-4",
                    lapply(image_urls, function(url) {
                        tags$img(src = url, class = "w-full rounded-lg shadow-md", style = "object-fit: contain; height: 250px;")
                    })
                )
            )
        ),
        br(),
        div(class = "action-button-container",
            actionButton(inputId = "want_one_button", label = "I want one!", class = "want-one-button")
        ),

        # signal the server that the viewer block is rendered and ready
        tags$script(HTML(sprintf("Shiny.setInputValue('trigger_viewer_%s', Math.random());", identifier)))
    )

    ui
}