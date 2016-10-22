
library('R2jags')
library('ggplot2')

x <- c(93000)
n <- length(x)

new.x <- 73000
corrected.new.x <- 7300 / 20 * 21

m <- NA
cluster <- NA

chains <- 4
nodes <- 4

test.poisson <- function (x, n) {
  system.time (m <- jags.parallel(
    model.file = 'poisson.signif.jags',
    data = list('x' = x,
                'n' = n),
    n.chains = chains,
    n.cluster = nodes,
    n.burnin = 5000,
    parameters.to.save = c("mu", "deviance", "pD", "rep.x"),
    jags.module = c("dic"),
    n.iter = 20000,
    n.thin = 4,
    DIC = TRUE
  ))
  m
}

tcg_plot <- function (m,
                      var = "rep.x") {
  qplot(m$BUGSoutput$sims.matrix[,var], geom="histogram", 
        xlab=var, fill=I("blue"), bins=50, alpha=I(0.5))
}

m

# rep.x.vals <- m$BUGSoutput$sims.matrix[,"rep.x"]
# length(rep.x.vals)
# mean(rep.x.vals <= corrected.new.x)
# 

