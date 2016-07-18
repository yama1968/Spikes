# power calculations

# power = proba of rejecting null hypothesis when specific alter hypo is true

diff      <- 10
sd1       <- 15
sd2       <- 17
sig.level <- 0.05
stat.pow  <- 0.8

pooled_std <- sqrt((sd1^2 + sd2^2) / 2)
delta      <- (0-10) / pooled_std

power.t.test(delta = delta, sig.level = sig.level, type = "two.sample", power = stat.pow)

power.t.test(delta = delta, sig.level = 0.07, type = "two.sample", power = stat.pow)


## Binomial is all false here!

get.delta <- function(m1, m2, sd1, sd2) {
  pooled_std <- sqrt((sd1 ^ 2 + sd2 ^ 2) / 2)

  (m1 - m2) / pooled_std
}

m1  <- 0.1
m2  <- 0.15
sd1 <- sqrt(m1 * (1 - m1))
sd2 <- sqrt(m2 * (1 - m2))

power.t.test(delta = get.delta(m1, m2, sd1, sd2),
             type = "two.sample",
             power = 0.9)

p.power.t.test <- function(p1, p2, power=0.9, sig.level=0.05) {
  sd1 <- sqrt(p1 * (1 - p1))
  sd2 <- sqrt(p2 * (1 - p2))

  power.t.test(delta = get.delta(m1, m2, sd1, sd2),
               sig.level = sig.level, type = "two.sample",
               power = power)
}

p.power.t.test(0.15, 0.1)

p.power.t.test(0.015, 0.01)

### power for binomial

library(Hmisc)

bsamsize(0.15, 0.1)
bsamsize(0.015, 0.01)
