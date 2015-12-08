

f <- function(x) 1:x
g <- function(l) list(me = mean(l), mx = max(l))
get.me <- function(l) lapply(l, function(x) x$me)
get.mx <- function(l) lapply(l, function(x) x$mx)

library(dplyr)

df2 <- data.frame(i = 1:3) %>%
  mutate(x = lapply(i, f)) %>%
  mutate(y = lapply(x, g)) %>%
  mutate(z.me = get.me(y),
         z.mx = get.mx(y)) %>%
  select(i, z.me, z.mx)

df2

