
library('rjags')

# prepare data

N <- 200
x <- (1:N)/N

set.seed(1234)
epsilon <- rnorm(N, 0, 0.1)
outliers <- rnorm(N, 0 , 1) * rbinom(N, 1, 0.05)
y <- 2 * x + 1 + epsilon
z <- y + outliers

# model

modelstring = "
data {
        for (i in 1:N) {
                u[i] <- z[i]
        }
}
model {
        for (i in 1:N) {
                y[i] ~ dnorm(a1 + b1 * (x[i] - mean(x)), tau1)
                z[i] ~ dnorm(a2 + b2 * (x[i] - mean(x)), tau2)
                u[i] ~ dt(a3 + b3 * (x[i] - mean(x)), tau3, k)
        }
        a1 ~ dnorm(0, 1/1000000)
        b1 ~ dnorm(0, 1/1000000)
        tau1 <- pow(sigma1, -2)
        sigma1 ~ dunif(0, 1000000)

        a2 ~ dnorm(0, 1/1000000)
        b2 ~ dnorm(0, 1/1000000)
        tau2 <- pow(sigma2, -2)
        sigma2 ~ dunif(0, 1000000)

        a3 ~ dnorm(0, 1/1000000)
        b3 ~ dnorm(0, 1/1000000)
        tau3 <- pow(sigma3, -2)
        sigma3 ~ dunif(0, 1000000)
        k ~ dunif(1, 5)
}
"

jags <- jags.model(textConnection(modelstring),
                   data = list('x' = x,
                               'y' = y,
                               'z' = z,
                               'N' = N),
                   n.chains = 4,
                   n.adapt = 1000)

system.time( { samples <- coda.samples(jags,
                                       c('a1', 'b1', 'sigma1',
                                         'a2', 'b2', 'sigma2',
                                         'a3', 'b3', 'sigma3', 'k'),
                                       10000)
} )

summary(samples)
