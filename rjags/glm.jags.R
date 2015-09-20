
library('dclone')
library('rjags')
library('snow')

set.seed(1234)

n <- 2000
x <- runif(n, -1, 1)
X <- model.matrix(~x)
beta <- c(2, -1)
mu <- crossprod(t(X), beta)
Y <- rpois(n, exp(mu))

foo.model <- function() {
        for (i in 1:n) {
                Y[i] ~ dpois(lambda[i])
                log(lambda[i]) <- inprod(X[i,], beta[1,])
        }
        for (j in 1:np) {
                beta[1,j] ~ dnorm(0, 0.001)
        }
}

dat <- list(Y=Y, X=X, n=n, np=ncol(X))

# load.module("foo")

m <- jags.fit(dat, "beta", foo.model)
# cl <- makePSOCKcluster(3)

## load glm module
# tmp <- clusterEvalQ(cl, library(dclone))
# parLoadModule(cl, "foo")

pm <- jags.parfit(4, dat, "beta", foo.model, flavour="jags", 
                 n.chains=4)

## chains are not identical -- this is good
pm[1:2,]
summary(pm)
