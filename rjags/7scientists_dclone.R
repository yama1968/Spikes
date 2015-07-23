
library('dclone')
library('rjags')

x <- c(-27.020,3.570,8.191,9.898,9.603,9.945,10.056)
n <- length(x)

m <- NA
cluster <- NA

chains <- 8
nodes <- 4

cluster <- makeCluster(spec = nodes,
                       type = "SOCK")

# cluster <- makeCluster(spec = nodes,
#                        type = "MPI")

m <- jags.parfit(cl = cluster,
                 model = '7scientists2.bug',
                 data = list('x' = x,
                             'n' = n),
                 n.chains = chains,
                 n.adapt = 1000,
                 params = c("mu", "sigma"),
                 n.iter = 100000)

summary(m)

stopCluster(cluster)

