
library(rethinking)

data(Howell1)
d <- Howell1

str(d)

d$weight.s <- (d$weight - mean(d$weight)) / sd(d$weight)

d$weight.s2 <- d$weight.s ^ 2

m4.5 <- map(
  alist(
    height    ~ dnorm(mu, sigma),
    mu       <- a + b1 * weight.s + b2 * weight.s2,
    a         ~ dnorm(178, 100),
    b1        ~ dnorm(0, 10),
    b2        ~ dnorm(0, 10),
    sigma     ~ dunif(0, 50)
  ),
  data = d
)

precis(m4.5)

m4.5_log <- map2stan(
  alist(
    height    ~ dnorm(mu, sigma),
    mu       <- a + b1 * weight.s + b2 * log(weight.s + beta),
    a         ~ dnorm(178, 100),
    b1        ~ dnorm(0, 10),
    b2        ~ dnorm(0, 10),
    beta      ~ dunif(2.2, 20),
    sigma     ~ dunif(0, 50)
  ),
  data = d
)

precis(m4.5_log)
