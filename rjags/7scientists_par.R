
library('R2jags')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

chains = 4

x_init = lapply(1:chains, function (i) { list(mu = i, sigma = rep(i/10, 7)) })


m <- jags.parallel (model.file = '7scientists2.bug',
           data = list('x' = x,
                       'n' = n),
           n.chains = chains,
           inits = x_init,
           n.iter = 100000,
           parameters.to.save = c("mu", "sigma") )

m$BUGSoutput
