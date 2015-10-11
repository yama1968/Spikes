library(shiny)

data(iris)

shinyServer(
    function(input, output) {
        
        output$text1 <- renderText({
            paste("You have selected ", input$var, ".", sep = "")
        })
        
        output$text2 <- renderText({
            paste("You chose a range from ",
                  input$range[[1]],
                  " to ",
                  input$range[[2]],
                  ".", sep = "")
        })
        
        output$gr1 <- renderPlot({
            boxplot(Sepal.Length ~ Species, data = iris)
        })
    }
)
