
library('rjags')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

jags <- jags.model('7scientists2.bug',
                   data = list('x' = x,
                               'n' = n),
                   n.chains = 4,
                   n.adapt = 1000)

system.time( { samples <- coda.samples(jags,
                                       c("mu", "sigma"),
                                       30000)
} )

plot(samples)