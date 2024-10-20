# shinyOTP <img src="hex_logo.png" align="right" width="164" height="201" />

`shinyOTP` is an R package that provides Shiny modules to easily implement 
One-Time Password (OTP) authentication in your Shiny applications. 

## Installation 

At the moment you can install only this version from GitHub:

```r
# Install devtools if necessary
# install.packages("devtools")

devtools::install_github("dejan94it/shinyOTP")
```
## Usage
Set email and password from which you want to send OTP code as environmental 
variable, and then just use ui and server functions.

Here is a minimal Shiny App:

```r
library(shiny)
library(shinyOTP)

Sys.setenv(SMTP_EMAIL = "youremail")
Sys.setenv(SMTP_PASSWORD = "yourpassword")

ui <- fluidPage(
  fluidRow(otp_ui("otp_module")),
  fluidRow(htmlOutput("do_something"))
)

server <- function(input, output, session) {
  is_verified <- otp_server(
    "otp_module",              
    smtp_email = "SMTP_EMAIL",      
    smtp_password = "SMTP_PASSWORD",
    smtp_host = "smtps.aruba.it",        
    smtp_port = 465,                            
    ssl = TRUE                                 
  )
  
  output$do_something <- renderUI({
    if(is_verified()){ 
      return(h2("Do Something when verified!")) 
    } else {
      return(NULL)
    } 
  })
}

shinyApp(ui, server)

```

