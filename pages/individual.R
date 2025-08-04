library(shiny)
library(shiny.router)
library(dplyr)

individual_page <- function(identifier, data) {

    dataIndividual <- data %>% filter(id == identifier)

    imageContainerId <- paste0("image-container-", identifier) # nolint

    image_urls <- paste0("Images/", dataIndividual$Name, c("1.jpg", "2.jpg", "3.jpg", "4.jpg"))

    div(
        class="w-full flex-grow bg-gray-800 p-8 rounded-xl shadow-lg",
        
        # Return button
        div(
        class = "return-button-container",
        tags$a(
            href = route_link("/"),
            class = "return-button",
            tags$img(
                class = "icon",
                src = "arrow-left-large.svg",
                alt = ""
            ),
            "Return"
        )
        ),
        
        # Disclaimer box
        div(
            class = "disclaimer-box",
            p("Disclaimer: By the user agreement of the studio, I cannot sell this miniature. However, If you want a similar one painted by me, please reach out so we can talk! I will have to charge for shipping and production costs.")
        ),
        
        # Main content area
        div(
            class="flex flex-col lg:flex-row gap-8",
            
            # Left Column: 3D Reconstruction and Main Image
            div(
                class="flex-1 flex flex-col items-center gap-6",
                tags$h2(
                    class="text-3xl font-bold text-white mb-4",
                    dataIndividual$Name
                ),
                div(
                    class="w-full rounded-xl shadow-lg",
                    div(
                        id = paste0("loader-", identifier),
                        class = "loader-container",
                        style = "display: none; height: 100%; display: flex; align-items: center; justify-content: center;",
                        div(
                            class = "loader",
                            "Loading 3D model..."
                        )
                    ),

                    # 3D viewer (initially hidden)
                    div(
                        class = "reconstruction-container",
                        id = paste0("viewer-", identifier),
                        style = "height: 100%; display: none;"
                    )
                ),
                tags$p(
                    class="text-sm text-gray-400 mt-2",
                    "(Drag to rotate 3D model - Placeholder for PLY reconstruction)"
                ),
                div(
                    class="w-full bg-gray-700 p-4 rounded-lg shadow-md flex items-center gap-4",
                    tags$a(
                        href = dataIndividual$BrandURL,
                        tags$img(
                            src = paste0("Logos/", dataIndividual$BrandLogo, sep=""),
                            alt = "",
                            class = "source-icon"
                        )
                    )
                ),
                tags$p(
                    class="text-md text-gray-400",
                    paste0("Painted On:", dataIndividual$PaintDate)
                )
            ),

            # Right Column: Additional Images
            div(
                class="flex-1 flex flex-col gap-6",
                tags$h3(
                    class="text-2xl font-bold text-white mb-2",
                    "Additional Views"
                ),
                div(
                    class="grid grid-cols-1 sm:grid-cols-2 gap-4",
                    # Aditional Images Here
                )
            )
        ),
        
        # Bottom - Action button
        div(
        class = "action-button-container",
        actionButton(
            inputId = "want_one_button",
            label = "I want one!",
            class = "want-one-button"
        )
        )
    )
}