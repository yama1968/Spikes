
library('dclone')
library('rjags')
library('snow')

# prepare data

# biz <- c(30, 0, 0, 50, 0, 20, 0, 0, 120, 0, 0, 0, 80, 0)
biz <- c(rep(0,11),
         14,
         0, 0,
         34.5,
         5,
         25,
         225,
         0,0, 0,0,
         90,
         68.5,
         0,
         50,
         0,0,0,
         132,
         0, 40)


# model

m <- NA
cluster <- NA

chains <- 4
nodes <- 4


runbiz <- function (biz,
                    chains = 4,
                    nodes = 4) {
        
        biz2 <- biz[biz>0]
        zero <- length(biz) - length(biz2)
        
        m <- NA
        cluster <- NA
        
        cluster <- makeCluster(spec = nodes,
                               type = "SOCK")
        
        system.time (m <- jags.parfit(cl = cluster,
                                      model = 'biz2.bug',
                                      data = list('biz2' = biz2, 'zero' = zero),
                                      n.chains = chains,
                                      n.adapt = 1000,
                                      params = c('p', 'a', 'b', 'm'),
                                      n.iter = 20000))
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

