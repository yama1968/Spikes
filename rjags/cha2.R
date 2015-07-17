
library('rjags')

nattempts  <- 950
nfails     <- nattempts-1   
n          <- 50    # Number of questions
z = c(rep(NA, nfails), 30)

myinits <- list(
        list(theta = 0.4),
        list(theta = 0.5)
)

jags <- jags.model('cha2.jags',
                   inits = myinits,
                   data = list('nattempts' = nattempts, 
                               'z' = z,
                               'n' = n),
                   n.chains = 2,
                   n.adapt = 1000)

system.time( { samples <- coda.samples(jags,
                                       c("theta"),
                                       5000)
} )

plot(samples)