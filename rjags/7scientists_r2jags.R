
library('R2jags')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

m <- NA
cluster <- NA

chains <- 4
nodes <- 4

system.time (m <- jags.parallel(
    model.file = '7scientists2.bug',
    data = list('x' = x,
                'n' = n),
    n.chains = chains,
    n.cluster = nodes,
    n.burnin = 4000,
    parameters.to.save = c("mu", "sigma", "deviance", "pD"),
    jags.module = c("dic"),
    n.iter = 100000,
    DIC = TRUE
))

m
