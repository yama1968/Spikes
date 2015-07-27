

N <- 2000
x <- 1:N
epsilon <- rnorm(N, 0, 10)
y <- 2 * x + 1 + epsilon


library('dclone')
library('rjags')

chains <- 4
nodes <- 4


cluster <- makeCluster(spec = nodes,
                       type = "SOCK")

system.time( {
m <- jags.parfit(cl = cluster, 
                 model = 'example2.bug',
                 data = list('x' = x,
                             "y" = y,
                             'N' = N),
                 n.chains = chains,
                 n.adapt = 1000,
                 n.iter = 20000,
                 params = c("a", "b") )
})

summary(m)

stopCluster(cluster)