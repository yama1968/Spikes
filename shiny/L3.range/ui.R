library(shiny)


shinyUI(fluidPage(
    titlePanel("censusVis"),
    
    sidebarLayout(
        sidebarPanel(
            p("Create demographic maps with 
              information from the 2010 US Census."),
            selectInput(
                "var",
                label = strong("Choose a variable to display"),
                choices = c("Percent White",
                            "Percent Black",
                            "Percent Hispanic",
                            "Percent Asian"),
                selected = "w"),
            sliderInput(
                "range",
                label = strong("Range of interest:"),
                min = 0, max = 100, value = c(0, 100))
        ),
        mainPanel(
            textOutput("text1"),
            textOutput("text2"),
            plotOutput("gr1")
        )
    )
))

