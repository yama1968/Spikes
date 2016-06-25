
library('R2jags')
library("ggplot2")
library(plotly)

test_control_group <- function (n0        =  1000,
                                pos0      =   100,
                                n1        = 10000,
                                n.chains  =     4,
                                n.nodes   =     4,
                                n.iter    =  2000,
                                n.burnin  =   500,
                                prior     = "unif") {
  
  data          = list(n0    = n0,
                       pos0  = pos0,
                       n1    = n1)
  
  if (prior == "beta") {
    model.file = "control_group_alt_prior.jags"
    data$a = 1
    data$b = 4
  } else
    model.file = "control_group.jags"
  
  jags.parallel(
    model.file    = model.file,
    data          = data,
    n.chains      = n.chains,
    n.cluster     = n.nodes,
    n.burnin      = n.burnin,
    n.iter        = n.iter,
    DIC           = TRUE,
    parameters.to.save  = c("p", "pos1", "deviance", "pD")
  )
}


tcg_plot <- function (m,
                      xlim = NULL,
                      var = "pos1") {
  if (is.null(xlim))
    if (var == "p") {
      xlim = c(0, 1.)
    } else {
      xlim = c(0, 10000)
    }
  qplot(m$BUGSoutput$sims.matrix[,var], geom="histogram", xlab=var, fill=I("blue"), bins=100, alpha=I(0.5), xlim=xlim)
  ggplotly()
}


loss_6 <- function(n1, pos1) {
  pos1 * (-100) + (n1 - pos1) * 600
}


apply_loss_fn <- function (m, n1, fun=loss_6) {
  matrix <- m$BUGSoutput$sims.matrix
  
  fun(n1, matrix[,"pos1"])
}


