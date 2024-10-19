#' OTP Server Module
#'
#' This function handles the server-side logic for generating and sending a One-Time Password (OTP)
#' via email, as well as verifying the OTP entered by the user in the associated UI module.
#'
#' @param id A unique identifier for the module namespace.
#' @param smtp_email_envvar The email address used to send the OTP, predefined as Environmental variable \code{Sys.setenv(SMTP_EMAIL = '')}.
#' @param smtp_password_envvar The password for the email account used to send the OTP,  predefined as Environmental variable \code{Sys.setenv(SMTP_PASSWORD = '')}.
#' @param smtp_host The SMTP host address used to send the email (e.g., "smtp.gmail.com").
#' @param smtp_port The SMTP port used by the host (e.g., 465 for SSL).
#' @param ssl A logical indicating whether to use SSL for the SMTP connection.
#'
#' @return A reactive value that returns \code{TRUE} if the OTP was successfully verified, and \code{FALSE} otherwise.
#'
#' @details
#' This server module works with \code{otp_ui()} to manage OTP functionality. When the user enters their email
#' and clicks "Send", an OTP code is generated and emailed. The user must then input the received OTP and click
#' "Verify". The server verifies whether the entered OTP matches the generated one.
#'
#' The OTP email is sent using the \code{blastula} package, which requires SMTP credentials (email, password, host, port).
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     otp_ui("otp_module")
#'   )
#'   server <- function(input, output, session) {
#'     otp_verified <- otp_server(
#'       "otp_module",
#'       smtp_email_envvar = "SMTP_EMAIL",
#'       smtp_password_envvar = "SMTP_PASSWORD",
#'       smtp_host = "smtp.yourprovider.com",
#'       smtp_port = 465,
#'       ssl = TRUE
#'     )
#'
#'     observe({
#'       if (otp_verified()) {
#'         print("OTP verified successfully")
#'       }
#'     })
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @export

otp_server <- function(id, smtp_email_envvar, smtp_password_envvar, smtp_host, smtp_port, ssl) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    otp_sent <- reactiveVal(NULL)
    otp_timestamp <- reactiveVal(NULL)

    email_feedback <- reactiveVal("")
    otp_feedback <- reactiveVal("")

    email_valid <- reactive({
      grepl("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", input$email)
    })

    generate_otp <- function() {
      sprintf("%06d", sample(0:999999, 1))
    }

    observeEvent(input$send, {
      if (email_valid()) {
        otp_code <- generate_otp()
        otp_sent(otp_code)  # Store OTP for verification later
        otp_timestamp(Sys.time())  # Store timestamp
        email <- input$email

        tryCatch({
          blastula::smtp_send(
            email = blastula::compose_email(
              body = blastula::md(glue::glue("Your OTP code is: {otp_code}")),
              footer = blastula::md(glue::glue("shinyOTP package by [dejan94it](https://github.com/dejan94it)"))
            ),
            from = Sys.getenv(smtp_email_envvar),
            to = email,
            subject = "Your OTP Code",
            credentials = blastula::creds_envvar(
              host = smtp_host,
              port = smtp_port,
              user = Sys.getenv(smtp_email_envvar),
              pass_envvar = smtp_password_envvar,
              use_ssl = ssl
            )
          )

          email_feedback("<span style='color: green;'>OTP has been sent to your email.</span>")

          updateActionButton(session, "send",  label = "Please wait...", disabled = TRUE)
          updateTextInput(session, "otp", value = "")
          later::later(
            function() {
              updateActionButton(session, "send", label = "Send", disabled = FALSE)
            }, delay = 30
          )

        }, error = function(e) {
          email_feedback("<span style='color: red;'>Failed to send OTP. Please try again later.</span>")
        })
      } else {
        email_feedback("<span style='color: red;'>Invalid email address. Please try again.</span>")
      }
    })


    verified <- reactiveVal(FALSE)
    observeEvent(input$verify, {
      # Check if OTP is within valid timeframe (e.g., 5 minutes)
      if (!is.null(otp_sent()) && input$otp == otp_sent() && difftime(Sys.time(), otp_timestamp(), units = "mins") <= 5) {
        otp_feedback("<span style='color: green;'>OTP is correct. Verification successful!</span>")
        verified(TRUE)
      } else {
        otp_feedback("<span style='color: red;'>OTP is incorrect or expired. Please try again.</span>")
        verified(FALSE)
      }
    })

    output$email_feedback <- renderUI({ HTML(email_feedback()) })
    output$otp_feedback <- renderUI({ HTML(otp_feedback()) })

    return(verified)
  })
}

