
library('dclone')
library('rjags')
library('snow')

# prepare data

biz <- c(30, 0, 0, 50, 0, 20, 0, 0, 120, 0, 0, 0, 80, 0)

# model

m <- NA
cluster <- NA

chains <- 4
nodes <- 4

cluster <- makeCluster(spec = nodes,
                       type = "SOCK")

system.time (m <- jags.parfit(cl = cluster,
                              model = 'biz.bug',
                              data = list('biz' = biz),
                              inits = function() 
                                      list(p = 0.5,
                                           a = 40,
                                           b = 1,
                                           choice = sapply(biz, function(x) ifelse(x>0, 1, 0))),
                              n.chains = chains,
                              n.adapt = 1000,
                              params = c('p', 'a', 'b'),
                              n.iter = 10000))


summary(m)

stopCluster(cluster)
