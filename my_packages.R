
p = c("caret", "e1071", "rjags", "dclone", "data.table", "dplyr",
      "ggplot2", "Hmisc", "extraTrees", "Rcpp", "devtools",
      "snow", "foreach", "reshape2", "survival", "randomForest",
      "tidyr", "car", "glmnet", "assertr", "doMC",
      "optparse", "forecast", "R2jags", "dclone", "rjags",
      "quantmod", "fArma", "fGarch",
      "RJSONIO", "zoo", "rmgarch", "PerformanceAnalytics",
      "tsoutliers", "reshape", "vcd", "fpc", "rrcov",
      "shiny", "UsingR",
      "maps", "mapproj", "corrplot",
      "manipulate", "ggfortify", "changepoint",
      "rbenchmark", "mclust",
      "bnlearn", "catnet", "rbmn",
      "readr", "kohonen", "dummies", "maptools", "rgeos",
      "apcluster", "igraph", "MonetDB.R", "RODBC", "RJDBC",
      "mixtools", "tclust",
      "Lahman", "VGAM", "RUnit",
      "devtools",
      "R2jags", "pROC", "xkcd", "plotly",
      #    "choroplethr", "choroplethrMaps",
      "dummies", "rio",
      "dendextend", "rafalib",
      "gridExtra", "ergm", "DT", "pryr",
      "shinydashboard", "visNetwork", "drat",
      "text2vec", "twitteR", "tidygraph", "lubridate", "xgboost", "party",
      "arules", "arulesViz",
      "vtreat", "WVPlots", 'mlr', 'ROSE',
      'xgboost', 'knitr', 'rmarkdown', 'PRROC', 'tidyverse',
      'ggforce', 'heatmaply',
      'C50')


p <- p[ !p %in% installed.packages()]

print(p)

install.packages(p)
#
devtools::install_github("holub008/xrf")

11# sudo apt-get install libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg
# sudo apt-get install jags
# sudo apt-get install libiodbc2-dev
#  sudo apt-get install libgsl0-dev gsl-bin libgeos-dev r-cran-rgl
# sudo apt-get install libxml2-dev

library(devtools)
install_github("ujjwalkarn/xda")


i.xgboost <- function() {
        require(devtools)
        devtools::install_github('dmlc/xgboost',subdir = 'R-package')
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
    devtools::install_github("apache/spark", ref = "master", subdir = "R/pkg")
}

i.shiny <- function () {
    require(devtools)
    devtools::install_github('rstudio/rsconnect')
}

i.bioclite <- function () {
    source("https://bioconductor.org/biocLite.R")
    biocLite("Rgraphviz")
}


source("https://bioconductor.org/biocLite.R")
biocLite("pcaMethods")
biocLite("multtest")
biocLite(c("Biobase", "org.Hs.eg.db", "AnnotationDbi"))
biocLite("alyssafrazee/RSkittleBrewer")
biocLite("GenomicRanges")
biocLite("SummarizedExperiment")
biocLite("DESeq2")
