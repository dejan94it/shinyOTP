#' OTP UI Module
#'
#' This function generates the user interface (UI) elements for an OTP (One-Time Password)
#' input form in a Shiny application. It includes an email input field, OTP code input field,
#' and action buttons for sending and verifying the OTP.
#'
#' @param id A unique identifier for the module namespace.
#'
#' @return A Shiny UI element containing input fields and action buttons for sending and verifying OTP codes.
#'
#' @details This UI module works in conjunction with the \code{otp_server()} server module
#' to implement OTP functionality. After the user enters their email and clicks "Send," an OTP
#' will be sent to the provided email. The user can then enter the OTP and click "Verify" to validate it.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     otp_ui("otp_module")
#'   )
#'   server <- function(input, output, session) {
#'     otp_server("otp_module", smtp_email_envvar = "SMTP_EMAIL", smtp_password_envvar = "SMTP_PASSWORD",
#'                smtp_host = "smtp.yourprovider.com", smtp_port = 465, ssl = TRUE)
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @export

otp_ui <- function(id) {
  ns <- NS(id)

  tagList(
    wellPanel(
      style = "padding: 15px; background-color: #f5f5f5; border: 1px solid #ddd;",

      fluidRow(
        column(6,
               div(
                 style = "display: flex; align-items: center;",
                 textInput(ns("email"), label = "Email", placeholder = "Enter your email", width = "70%"),
                 actionButton(ns("send"), label = "Send", class = "btn-primary", style = "margin-left: 10px;", disabled = FALSE)
               ),
               htmlOutput(ns("email_feedback")) # Placeholder for email feedback
        )
      ),

      fluidRow(
        column(6,
               div(
                 style = "display: flex; align-items: center;",
                 textInput(ns("otp"), label = "OTP Code", placeholder = "Enter the OTP code", width = "70%"),
                 actionButton(ns("verify"), label = "Verify", class = "btn-success", style = "margin-left: 10px;")
               ),
               htmlOutput(ns("otp_feedback")) # Placeholder for OTP feedback
        )
      )
    )
  )
}
