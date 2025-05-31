library(shiny)
library(shiny.router)
library(dplyr)

individual_page <- function(identifier, data) {

    dataIndividual <- data %>% filter(id == identifier)

    imageContainerId <- paste0("image-container-", identifier)

    image_urls <- paste0("Images/", dataIndividual$Name, c("1.jpg", "2.jpg", "3.jpg", "4.jpg"))

    div(
        class = "individual-page-container",
        
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
            class = "product-display-container",
            
            # Left - Logo
            div(
                class = "product-logo",
                tags$a(
                    href = dataIndividual$BrandURL,
                    tags$img(
                        src = paste0("Logos/", dataIndividual$BrandLogo, sep=""),
                        alt = "",
                        class = "source-icon"
                    )
                )
            ),
        
            # Center - Product image
            div(
                class = "product-image-container",
                id = paste0("image-container-", identifier),
                
                # Image carousel (initially visible)
                div(
                    id = paste0("image-view-", identifier),
                    class = "css-carousel-slides",
                    lapply(image_urls, function(url) {
                        div(
                            class = "css-carousel-slide",
                            tags$img(src = url)
                        )
                    })
                ),
                
                # 3D viewer (initially hidden)
                div(
                    class="reconstruction-container",
                    id = paste0("viewer-", identifier),
                    style="height: 100%"
                )
            ),
        
            # Right - View options
            div(
                class = "view-options",
                actionButton(
                    inputId = paste0("btn_3d_", identifier),
                    label = "3D",
                    class = "view-option-button"
                ),
                actionButton(
                    inputId = paste0("btn_image_", identifier),
                    label = "Image",
                    class = "view-option-button"
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