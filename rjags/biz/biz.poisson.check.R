
library('dclone')
library('rjags')
library('snow')

# prepare data

# biz <- c(30, 0, 0, 50, 0, 20, 0, 0, 120, 0, 0, 0, 80, 0)
biz <- c(rep(0.0,11),
         14.0,
         0.0, 0.0,
         34,
         5,
         25,
         225,
         0,0, 0,0,
         90,
         68,
         0,
         50,
         0,0,
         241,
         0, 50,0,0,0,0,
         5, 95, 0, 35)


# model

m <- NA
cluster <- NA

chains <- 4
nodes <- 4


runbiz <- function (biz) {
    m <- NA
    
    nb <- 3
    
    cluster <- makeCluster(spec = nodes,
                           type = "SOCK")
    
    system.time (m <- jags.parfit(cl = cluster,
                                  model = 'biz.poisson.check.bug',
                                  data = list('biz' = biz, 'K' = max(biz) + 1, 'N' = length(biz)),
                                  n.chains = chains,
                                  params = c('mu', 'true_mean.rep', 'G', 'G.rep', 'P'),
                                  n.iter = 10000,
                                  n.adapt = 1000))
    stopCluster(cluster)
    
    m
}


runmul <- function (b = biz, steps = 3) {
    
    N = length(b)
    
    for (i in 1:(steps)) {
        deb <- round(N*(i-1)/(steps+1)+1)
        fin <- round(N*(i+1)/(steps+1))
        m <- runbiz(b[deb:fin])
        print (summary(m))
    }
}

system.time(m <- runbiz(biz) )
summary(m)
