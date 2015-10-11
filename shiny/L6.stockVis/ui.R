library(shiny)


shinyUI(fluidPage(
    titlePanel("stockVis"),
    
    sidebarLayout(
        sidebarPanel(
            p("Select a stock to examine, information will be
              collected from yahoo finance."),
            textInput("symbol",
                label = h3("Symbol"),
                value = "SPY"),
            dateRangeInput("dates", 
                label = h3("Date range"),
                start = "2010-01-01",
                end   = "2015-01-01"),
            checkboxInput("log", label = "Plot on log scale", value = F),
            checkboxInput("adjust", label = "Adjust for inflation", value = F)
        ),
        
        mainPanel(
            plotOutput("stock")
        )
    )
))

