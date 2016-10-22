#

library(shiny)

sliderInput(inputId = "num",
            label = "Choose a number",
            value = 25, min = 1, max = 100)