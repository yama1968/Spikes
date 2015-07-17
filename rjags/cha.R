
library('rjags')

nattempts  <- 100
nfails     <- nattempts-1   
n          <- 50    # Number of questions
z = c(rep(NA,nfails), 30)
y = c(rep(1,nfails), 0)

data <- list("nattempts","n","z","y") # to be passed on to WinBUGS

jags <- jags.model('cha.jags',
                   data = list('nattempts' = nattempts, 
                               'y' = y,
                               'z' = z,
                               'n' = n),
                   n.chains = 2,
                   n.adapt = 1000)

system.time( { samples <- coda.samples(jags,
                                       c("theta"),
                                       5000)
} )

plot(samples)