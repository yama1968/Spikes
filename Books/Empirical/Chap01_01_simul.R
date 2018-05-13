
library(dplyr)

num_trials <- 10e6
#num_trials <- 10e4

simulations <- data_frame(
  true_average = rbeta(num_trials, 81, 219),
  hits         = rbinom(num_trials, 300, true_average)
)

simulations

hits100 <- simulations %>%
  filter(hits == 100)

hits100

library(ggplot2)

# plot density of players with 100 hits over 300 bats
ggplot(hits100, aes(true_average)) +
  geom_histogram(aes(y = ..density..)) +
  stat_function(fun = dbeta,
                args = list(shape1 = 81 + 100, shape2 = 219 + 200),
                col = 'red')

# 60 vs 80, 100

simulations %>%
  filter(hits %in% c(60, 80, 100)) %>%
  ggplot(aes(true_average, color = factor(hits))) +
    geom_density() +
    labs(x = "True average of players with H hists / 300 at-bats",
         color = "H")
