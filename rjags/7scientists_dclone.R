
library('dclone')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

m <- NA

cluster <- makeCluster(spec = rep("localhost", 4),
                       type = "PSOCK")

m <- jags.parfit(cl = cluster,
                 model = '7scientists2.bug',
                 data = list('x' = x,
                             'n' = n),
                 n.chains = 4,
                 n.adapt = 1000,
                 params = c("mu", "sigma"),
                 n.iter = 100000)


summary(m)