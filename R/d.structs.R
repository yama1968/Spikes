

f <- function(x) 1:x
g <- function(l) list(me = mean(l), mx = max(l), ss2 = mean(l**2))
get.me <- function(l) sapply(l, function(x) x$me)
get.mx <- function(l) sapply(l, function(x) x$mx)
get.ss2 <- function(l) sapply(l, function(x) x$ss2)

library(dplyr)

N = 10


system.time({
  df2 <- data.frame(i = 1:N) %>%
    mutate(x = lapply(i, f)) %>%
    mutate(y = lapply(x, g)) %>%
    mutate(z.me  = get.me(y),
           z.mx  = get.mx(y),
           z.ss2 = (get.ss2(y))) %>%
    select(-x, -y)
  
  print(mean(df2$z.ss2))
})

