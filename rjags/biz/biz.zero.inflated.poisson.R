
library('dclone')
library('rjags')
library('snow')

# prepare data

# biz <- c(30, 0, 0, 50, 0, 20, 0, 0, 120, 0, 0, 0, 80, 0)
biz <- c(rep(0,11),
         14,
         0, 0,
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


runbiz <- function (biz, nd = nodes, ch = chains) {

    cluster <- makeCluster(spec = nd,
                           type = "SOCK")
    
    system.time (m <- jags.parfit(cl = cluster,
                                  model = 'biz.zero.inflated.bug',
                                  data = list('biz' = biz),
                                  n.chains = ch,
                                  inits = function()
                                       list(group=1*(biz>0)),
                                  params = c('mu', 'p', 'true.mean.rep'),
                                  n.iter = 2000,
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
