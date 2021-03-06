
library('R2jags')


# prepare data

# biz <- c(30, 0, 0, 50, 0, 20, 0, 0, 120, 0, 0, 0, 80, 0)
data <- c(rep(0,11),
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
         5, 95, 0, 35,
         0, 290)


# model

m <- NA
cluster <- NA

chains <- 4
nodes <- 4


runbiz <- function(b, nd = nodes, ch = chains) {

    system.time(m <- jags.parallel(
        model.file    = 'biz.zero.inflated.gamma.bug',
        data          = list('biz' = b),
        n.chains      = ch,
        n.cluster     = nd,
        n.burnin      = 1000,
        inits         = function()
                          list(group = 1*(b > 0)),
        parameters.to.save = c('p', 'true.mean.rep', 'sigma', 'a', 'b', 'pval',
                               'Deviance', 'deviance', 'pD'),
        jags.module   = c("dic"),
        n.iter        = 20000,
        DIC           = TRUE,
        n.thin        = 4
    ))
    
    m
}


runmul <- function(b = data, steps = 3) {
    
    N       <- length(b)
    shift   <- N %% (steps + 1)
    
    for (i in 1:(steps)) {
        deb <- round(N*(i - 1)/(steps + 1) + 1 + shift)
        fin <- round(N*(i + 1)/(steps + 1) + shift)
        m <- runbiz(b[deb:fin])
        print(m)
    }
}

system.time(m <- runbiz(data) )
m
