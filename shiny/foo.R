require(shiny)
require(ggplot2)

server <- function(input, output) {
 output$hist <- renderPlot({
   hist(x = rnorm(input$num), 
        main = "My histogram",
        xlim = c(-4, 4),
        breaks = input$breaks)
 })
}

ui <- fluidPage(
  sliderInput(inputId = "num",
              label = "Choose a number of samples",
              value = 25, min = 1, max = 5000),
  sliderInput(inputId = "breaks",
              label = "Choose a number of breaks",
              value = 25, min = 1, max = 500),
  plotOutput("hist")
)

shinyApp(ui = ui, server = server)
