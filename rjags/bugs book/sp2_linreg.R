
library('rjags')

# prepare data

N <- 200
x <- (1:N)/N

set.seed(1234)
epsilon <- rnorm(N, 0, 0.2)
y <- 2 * x + 1 + epsilon

# model

modelstring = "
data {
        for (i in 1:N) {
                z[i] <- y[i]
        }
}
model {
        for (i in 1:N) {
               y[i] ~ dnorm(a1 + b1 * (x[i] - mean(x)), tau1)
               z[i] ~ dnorm(a2 + b2 * x[i], tau2)
        }
        a1 ~ dnorm(0, 1/1000000)
        b1 ~ dnorm(0, 1/1000000)
        tau1 <- pow(sigma1, -2)
        sigma1 ~ dunif(0, 1000000)
        a2 ~ dnorm(0, 1/1000000)
        b2 ~ dnorm(0, 1/1000000)
        tau2 <- pow(sigma2, -2)
        sigma2 ~ dunif(0, 1000000)
}
"

jags <- jags.model(textConnection(modelstring),
                   data = list('x' = x,
                               'y' = y,
                               'N' = N),
                   n.chains = 4,
                   n.adapt = 1000)

system.time( { samples <- coda.samples(jags,
                                       c('a1', 'b1', 'a2', 'b2'),
                                       5000)
} )

summary(samples)
