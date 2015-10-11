require(shiny)

shinyUI(fluidPage(
    titlePanel(h1("my very own title panel")),
    
    sidebarLayout(position = "right",
        sidebarPanel("not really my own sidebar panel"),
        mainPanel(
            h1("a very main panel", align = "center"),
            h2("second level title"),
            h3("third level ttt"),
            p("Just to continue with our small conversation"))
    )
))
