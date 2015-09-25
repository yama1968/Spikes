
p = c("caret", "e1071", "rjags", "dclone", "data.table", "dplyr",
      "ggplot2", "Hmisc", "extraTrees", "Rcpp", "devtools",
      "snow", "foreach", "reshape2", "survival", "randomForest",
      "tidyr", "car", "glmnet", "assertr", "doMC",
      "optparse", "forecast")

p <- p[ ! p %in% installed.packages()]

print (p)

install.packages(p)

i.xgboost <- function () {
        require(devtools)
        devtools::install_github('dmlc/xgboost',subdir='R-package')
}