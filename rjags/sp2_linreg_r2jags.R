

N <- 2000
x <- 1:N
epsilon <- rnorm(N, 0, 10)
y <- 2 * x + 1 + epsilon


library('R2jags')

chains <- 4
nodes <- 4

system.time (m <- jags.parallel(
    model.file = 'example2.bug',
    data = list('x' = x,
                'y' = y,
                'N' = N),
    n.chains = chains,
    n.cluster = nodes,
    n.burnin = 4000,
    n.thin = 4,
    parameters.to.save = c("a", "b", "deviance"),
    jags.module = c("dic"),
    n.iter = 20000,
    DIC = TRUE
))


print(m)
