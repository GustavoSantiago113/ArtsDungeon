library(shiny)
library(shiny.router)

individual_page <- function() {

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
        p("Disclaimer: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
        ),
        
        # Main content area
        div(
        class = "product-display-container",
        
        # Left - Logo
        div(
            class = "product-logo",
            img(src = "lsm_logo.png", alt = "LSM Logo")
        ),
        
        # Center - Product image
        div(
            class = "product-image-container",
            img(
            id = "product-main-image",
            class = "product-image",
            src = "placeholder_image.jpg",
            alt = "Product Image"
            ),
            textOutput("mini_id_display")
        ),
        
        # Right - View options
        div(
            class = "view-options",
            div(
            class = "view-option-button",
            "3D"
            ),
            div(
            class = "view-option-button",
            "360"
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