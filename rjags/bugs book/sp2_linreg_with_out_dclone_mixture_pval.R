
library('dclone')
library('rjags')
library('snow')

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
                              model = 'sp2_linreg_with_out_mixture_pval.bug',
                              data = list('x' = x,
                                          'y' = y,
                                          'z' = z,
                                          'N' = N),
                              n.chains = chains,
                              n.adapt = 1000,
                              params = c('a1', 'b1', 'sigma1',
                                         'a2', 'b2', 'sigma2',
                                         'a3', 'b3', 'sigma',
                                         'u.p', 'v.p', 'pClust'),
                              n.iter = 10000))


summary(m)

stopCluster(cluster)

# 
# Parallel computation in progress
# 
# utilisateur     système      écoulé 
# 1.649       1.280    1104.299 
# 
# > summary(m)
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
# a1        1.99993 0.002203 1.102e-05      1.106e-05
# a2        2.00011 0.002318 1.159e-05      1.140e-05
# a3        2.00055 0.002333 1.167e-05      1.223e-05
# b1        2.00707 0.007636 3.818e-05      3.818e-05
# b2        2.01153 0.008124 4.062e-05      4.043e-05
# b3        2.00450 0.008094 4.047e-05      4.247e-05
# pClust[1] 0.49965 0.457503 2.288e-03      4.687e-05
# pClust[2] 0.50035 0.457503 2.288e-03      4.687e-05
# sigma[1]  0.48741 0.391683 1.958e-03      3.661e-04
# sigma[2]  0.48630 0.390574 1.953e-03      3.788e-04
# sigma1    0.09900 0.001561 7.803e-06      7.969e-06
# sigma2    0.07764 0.001860 9.298e-06      9.083e-06
# u.p       0.50005 0.010999 5.500e-05      5.403e-05
# v.p       0.49924 0.011101 5.550e-05      5.602e-05
# 
# 2. Quantiles for each variable:
#         
#         2.5%     25%     50%     75%   97.5%
# a1        1.99559 1.99845 1.99992 2.00142 2.00425
# a2        1.99560 1.99856 2.00010 2.00168 2.00467
# a3        1.99598 1.99897 2.00055 2.00211 2.00512
# b1        1.99203 2.00191 2.00707 2.01224 2.02196
# b2        1.99560 2.00607 2.01150 2.01695 2.02744
# b3        1.98860 1.99904 2.00444 2.00994 2.02043
# pClust[1] 0.03321 0.04196 0.50068 0.95746 0.96615
# pClust[2] 0.03385 0.04254 0.49932 0.95804 0.96679
# sigma[1]  0.09665 0.09954 0.36683 0.86931 1.01070
# sigma[2]  0.09671 0.09958 0.36586 0.86742 1.01169
# sigma1    0.09600 0.09794 0.09898 0.10004 0.10210
# sigma2    0.07408 0.07638 0.07762 0.07888 0.08136
# u.p       0.47850 0.49250 0.50000 0.50750 0.52150
# v.p       0.47750 0.49150 0.49950 0.50650 0.52100