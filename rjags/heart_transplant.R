
library('rjags')

sP <- c(2,3,4,4,6,7,10,12)

jags <- jags.model("heart_transplant.bug",
                   data = list("sP" = sP),
                   n.chains = 4,
                   n.adapt = 2000)

samples <- coda.samples(jags,
                        c("Is", "pT", "surv.t", "theta"), 10000)

summary(samples)
