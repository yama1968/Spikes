library(plotly)
mydata = read.csv("density_plot.txt")
df = as.data.frame(mydata)
plot_ly(df, x = Y, y = X, z = Z, group = X, type = "scatter3d", mode = "lines") 

plot_ly(df, x = Y, y = X, z = Z, group = X, type = "scatter3d", mode = "bars") 


library(plotly)
set.seed(100)
d <- diamonds[sample(nrow(diamonds), 1000), ]
plot_ly(d, x = carat, y = price, text = paste("Clarity: ", clarity),
        mode = "markers", color = carat, size = carat)

p <- ggplot(data = d, aes(x = carat, y = price)) +
  geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
  geom_smooth(aes(colour = cut, fill = cut)) + facet_wrap(~ cut)

(gg <- ggplotly(p))

#

str(p <- plot_ly(economics, x = date, y = uempmed))
p %>%
  add_trace(y = fitted(loess(uempmed ~ as.numeric(date))), x = date) %>%
  layout(title = "Median duration of unemployment (in weeks)",
         showlegend = FALSE) %>%
  dplyr::filter(uempmed == max(uempmed)) %>%
  layout(annotations = list(x = date, y = uempmed, text = "Peak", showarrow = T))



library(tidyr)
library(plotly)
s <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/school_earnings.csv")
s <- s[order(s$Men), ]
gather(s, Sex, value, Women, Men) %>%
  plot_ly(x = value, y = School, mode = "markers",
          color = Sex, colors = c("pink", "blue")) %>%
  add_trace(x = value, y = School, mode = "lines",
            group = School, showlegend = F, line = list(color = "gray")) %>%
  layout(
    title = "Gender earnings disparity",
    xaxis = list(title = "Annual Salary (in thousands)"),
    margin = list(l = 65)
  )

##

plot_ly(midwest, x = percollege, color = state, type = "box")

