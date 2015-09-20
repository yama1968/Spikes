
library(dclone)
library('rjags')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

m <- NA

chains <- 8
nodes <- 4

m <- jags.parfit(cl = nodes,
                 model = '7scientists2.bug',
                 data = list('x' = x,
                             'n' = n),
                 n.chains = chains,
                 n.adapt = 1000,
                 params = c("mu", "sigma"),
                 n.iter = 50000)

summary(m)

plot(m, trace=FALSE)

vars <- dctable(m)
print (vars)
plot(vars)
