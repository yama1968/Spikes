
p = c("caret", "e1071", "rjags", "dclone", "data.table", "dplyr",
      "ggplot2", "Hmisc", "extraTrees", "Rcpp", "devtools",
      "snow", "foreach", "reshape2", "survival", "randomForest",
      "tidyr", "car", "glmnet", "assertr", "doMC",
      "optparse", "forecast", "R2jags", "dclone", "rjags",
      "quantmod", "fArma", "fGarch",
      "RJSONIO", "zoo", "rmgarch", "PerformanceAnalytics")

p <- p[ ! p %in% installed.packages()]

print (p)

install.packages(p)

i.xgboost <- function () {
        require(devtools)
        devtools::install_github('dmlc/xgboost',subdir='R-package')
}

# sudo apt-get install libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg