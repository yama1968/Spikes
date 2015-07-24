
library('rjags')

jags <- jags.model("coins.bug",
                   n.chains = 4,
                   n.adapt = 1000)

samples <- coda.samples(jags, c("coin.prob"), 5000)

summary(samples)
