# shinyOTP

`shinyOTP` is an R package that provides Shiny modules to easily implement One-Time Password (OTP) authentication in your Shiny applications.

## Installation

At the moment you can install only this version from GitHub:

```r
# Install devtools if necessary
# install.packages("devtools")

devtools::install_github("dejan94it/shinyOTP")
```
## Usage
Set email and password from which you want to send OTP code as environmental variable, and then just use ui and server functions.

Here is a minimal Shiny App:

```r
library(shiny)
library(shinyOTP)

Sys.setenv(SMTP_EMAIL = "youremail")
Sys.setenv(SMTP_PASSWORD = "yourpassword")

ui <- fluidPage(
  otp_ui("otp_module") 
)

server <- function(input, output, session) {
  otp_server(
    "otp_module",              
    smtp_email = "SMTP_EMAIL",      
    smtp_password = "SMTP_PASSWORD",
    smtp_host = "smtps.aruba.it",        
    smtp_port = 465,                            
    ssl = TRUE                                 
  )
}

shinyApp(ui, server)

```

