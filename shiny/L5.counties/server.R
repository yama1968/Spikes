library(shiny)

source("helpers.R")

counties <- readRDS("data/counties.rds")

library(maps)
library(mapproj)

shinyServer(
    function(input, output) {
        
        output$text1 <- renderText({
            race <- input$var
            paste("Map for ", race)
        })
        
        output$map <- renderPlot({
            race <- input$var
            percent_map(var = counties[,race], 
                        color = switch(race,
                                       "white" = "darkgreen",
                                       "black" = "black",
                                       "hispanic" = "red",
                                       "asian" = "orange"
                        ),
                        legend.title = paste("%", race),
                        min = input$range[[1]],
                        max = input$range[[2]])
        })
    }
)

