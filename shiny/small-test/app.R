require(shiny)
require(ggplot2)

server <- function(input, output) {
  d <- reactive({ 
    rnorm(input$num)
  })
  title <- eventReactive(input$update,
                         { input$title },
                         ignoreNULL = FALSE)
  output$hist <- renderPlot({
    print(qplot(x = d(),
                main = title(),
                xlim = c(-4, 4),
                bins = input$breaks,
                geom = "histogram",
                xlab = "Valeurs"))
  })
  output$stats <- renderPrint({
    summary(d())
  })
}

ui <- fluidPage(
  sliderInput(inputId = "num",
              label = "Choose a number of samples",
              value = 500, min = 1, max = 50000),
  sliderInput(inputId = "breaks",
              label = "Choose a number of breaks",
              value = 25, min = 1, max = 500),
  textInput(inputId = "title",
            label = "Write a title (please!)",
            value = "Histogram of Random normal values"),
  actionButton(inputId = "update",
               label = "Update title"),
  plotOutput("hist"),
  verbatimTextOutput("stats")
)

shinyApp(ui = ui, server = server)
