
library('dclone')
library('rjags')

# prepare data

N <- 200
x <- (1:N)/N

set.seed(1234)
epsilon <- rnorm(N, 0, 0.1)
outliers <- rnorm(N, 0 , 1) * rbinom(N, 1, 0.05)
y <- 2 * x + 1 + epsilon
z <- y + outliers

# model

m <- NA
cluster <- NA

chains <- 4
nodes <- 4

cluster <- makeCluster(spec = nodes,
                       type = "SOCK")

system.time (m <- jags.parfit(cl = cluster,
                              model = 'sp2_linreg_with_out.bug',
                              data = list('x' = x,
                                          'y' = y,
                                          'z' = z,
                                          'N' = N),
                              n.chains = chains,
                              n.adapt = 1000,
                              params = c('a1', 'b1', 'sigma1',
                                         'a2', 'b2', 'sigma2',
                                         'a3', 'b3', 'sigma3',
                                         'a4', 'b4', 'sigma4', 'p', 'sigma5'),
                              n.iter = 10000))


summary(m)

stopCluster(cluster)
