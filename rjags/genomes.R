#

library('dclone')
library('rjags')

data = list(NAA = c(427, 95, 0), 
            NAB = c(108, 161, 71), 
            NBB = c(0, 64, 74))

cluster <- NA
chains  <- 32
nodes   <- 4

cluster <- makeCluster(spec = nodes,
                       type = "SOCK")

system.time (m <- jags.parfit(cl = cluster,
                              model = "genomes.bug",
                              data = data,
                              n.chains = chains,
                              n.adapt = 4000,
                              params = c("p", "sigma"),
                              n.iter = 10000))

summary(m)

stopCluster(cluster)