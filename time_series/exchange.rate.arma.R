#

library(R2jags)
source("helper.R")

x <- read.table(download.if.needed("pounds_nz.dat"), header = T)
x.ts <- ts(x, start = 1991, frequency = 4)


train.jags <- function(y         = x$xrate,
                       model     = "arma2.2.jags",
                       chains    = 8,
                       nodes     = 8,
                       burn      = 1000,
                       iter      = 10000) {
    
    system.time(m <- jags.parallel(
        model.file          = model,
        data                = list(y = y),
        n.chains            = chains,
        n.cluster           = nodes,
        n.burnin            = burn,
        parameters.to.save  = c('deviance', 'delta', 'theta', 'c', 'sigma', 'phi', 'm', 'p'),
        jags.module         = c("dic"),
        n.iter              = iter,
        DIC                 = TRUE,
        n.thin              = 2
    ))
    
    m
}

get.residual <- function(m,
                         y        = x$xrate) {
    y - m$BUGSoutput$mean$m
}

