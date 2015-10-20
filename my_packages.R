
p = c("caret", "e1071", "rjags", "dclone", "data.table", "dplyr",
      "ggplot2", "Hmisc", "extraTrees", "Rcpp", "devtools",
      "snow", "foreach", "reshape2", "survival", "randomForest",
      "tidyr", "car", "glmnet", "assertr", "doMC",
      "optparse", "forecast", "R2jags", "dclone", "rjags",
      "quantmod", "fArma", "fGarch",
      "RJSONIO", "zoo", "rmgarch", "PerformanceAnalytics",
      "tsoutliers", "reshape", "vcd", "fpc", "rrcov",
      "shiny", "UsingR",
      "maps", "mapproj", "corrplot")

p <- p[ ! p %in% installed.packages()]

print(p)

install.packages(p)

# sudo apt-get install libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg
# sudo apt-get install jags

i.xgboost <- function () {
        require(devtools)
        devtools::install_github('dmlc/xgboost',subdir='R-package')
}

i.anomaly.detection <- function() {
  require(devtools)
  devtools::install_github("twitter/AnomalyDetection")
}

i.breakout <- function () {
  require(devtools)
  devtools::install_github("twitter/BreakoutDetection")
}

i.h2o <- function () {
  require(devtools)
  install.packages(c("h2o","SuperLearner","cvAUC"))
  install_github("h2oai/h2o-3/h2o-r/ensemble/h2oEnsemble-package")
}

i.sparkr <- function (){
    require(devtools)
    devtools::install_github("apache/spark", ref="master", subdir="R/pkg")
}

i.shiny <- function () {
    require(devtools)
    devtools::install_github('rstudio/rsconnect')
}


