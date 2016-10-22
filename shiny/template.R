require(shiny)

server <- function(input, output) {
}

ui <- fluidPage(
  "Hello, World!"
)

shinyApp(ui = ui, server = server)
