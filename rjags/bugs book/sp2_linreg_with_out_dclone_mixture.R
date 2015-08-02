
library('dclone')
library('rjags')

# prepare data

N <- 2000
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
                              model = 'sp2_linreg_with_out_mixture.bug',
                              data = list('x' = x,
                                          'y' = y,
                                          'z' = z,
                                          'N' = N),
                              n.chains = chains,
                              n.adapt = 1000,
                              params = c('a1', 'b1', 'sigma1',
                                         'a2', 'b2', 'sigma2',
                                         'a3', 'b3', 'sigma',
                                         'pClust'),
                              n.iter = 10000))


summary(m)

stopCluster(cluster)


Parallel computation in progress

utilisateur     système      écoulé 
1.369       1.136     940.400 

> summary(m)
# 
# Iterations = 2001:12000
# Thinning interval = 1 
# Number of chains = 4 
# Sample size per chain = 10000 
# 
# 1. Empirical mean and standard deviation for each variable,
# plus standard error of the mean:
#         
#         Mean       SD  Naive SE Time-series SE
# a1        1.99990 0.002208 1.104e-05      1.104e-05
# a2        2.00010 0.002326 1.163e-05      1.156e-05
# a3        2.00056 0.002336 1.168e-05      1.224e-05
# b1        2.00703 0.007738 3.869e-05      3.891e-05
# b2        2.01154 0.008109 4.055e-05      3.991e-05
# b3        2.00454 0.008069 4.035e-05      4.341e-05
# pClust[1] 0.72832 0.396251 1.981e-03      4.662e-05
# pClust[2] 0.27168 0.396251 1.981e-03      4.662e-05
# sigma[1]  0.29415 0.339304 1.697e-03      2.724e-04
# sigma[2]  0.68017 0.341890 1.709e-03      4.659e-04
# sigma1    0.09900 0.001594 7.970e-06      7.969e-06
# sigma2    0.07763 0.001846 9.232e-06      9.232e-06
# 
# 2. Quantiles for each variable:
#         
#         2.5%     25%     50%     75%   97.5%
# a1        1.99555 1.99842 1.99990 2.00137 2.00425
# a2        1.99558 1.99852 2.00010 2.00167 2.00464
# a3        1.99592 1.99900 2.00057 2.00216 2.00509
# b1        1.99184 2.00184 2.00701 2.01227 2.02217
# b2        1.99564 2.00612 2.01152 2.01699 2.02744
# b3        1.98875 1.99912 2.00457 2.00998 2.02034
# pClust[1] 0.03494 0.71337 0.95481 0.95978 0.96703
# pClust[2] 0.03297 0.04022 0.04519 0.28663 0.96506
# sigma[1]  0.09637 0.09880 0.10034 0.23928 0.98040
# sigma[2]  0.09733 0.51316 0.83613 0.90202 1.02824
# sigma1    0.09594 0.09790 0.09897 0.10006 0.10220
# sigma2    0.07408 0.07637 0.07760 0.07886 0.08133
