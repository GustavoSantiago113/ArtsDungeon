library(shiny)
library(shiny.router)
library(dplyr)

individual_page <- function(identifier, data) {

    dataIndividual <- data %>% filter(id == identifier)

     imageContainerId <- paste0("image-container-", identifier)

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
                        src = paste0("https://lh3.googleusercontent.com/d/", dataIndividual$BrandLogo, sep=""),
                        alt = "",
                        class = "source-icon"
                    )
                )
            ),
        
            # Center - Product image
            div(
                class = "product-image-container",
                # Add an ID to target this container specifically
                id = imageContainerId,
                img(
                    id = "product-main-image",
                    class = "product-image",
                    src = paste0("https://lh3.googleusercontent.com/d/", dataIndividual$ImageURL, sep=""),
                    alt = "Product Image"
                ),
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