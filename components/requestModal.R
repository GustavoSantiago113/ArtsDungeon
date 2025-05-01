library(shiny)

request_one <- function(){
  showModal(
    modalDialog(
      title = "Request a Mini",
      div(
        class = "request-section",
        tags$h3(
            "Send me a message and I will return to you as soon as possible!"
        ),
        textInput(
          inputId = "name",
          label = "",
          placeholder = "Name"
        ),
        textInput(
          inputId = "email",
          label = "",
          placeholder = "Email"
        ),
        textInput(
          inputId = "country",
          label = "",
          placeholder = "Country"
        ),
        textAreaInput(
            inputId = "message",
            label = "",
            placeholder = "Hello! I want this mini"
        )
      ),
      easyClose = TRUE,
      footer = tagList(
        actionButton("sendEmail", "Send", class = "contribute-button")
      )
    )
  )
}