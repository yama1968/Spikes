
p = c("caret", "e1071", "rjags", "dclone", "data.table", "dplyr",
      "ggplot2", "Hmisc", "extraTrees", "Rcpp", "devtools",
      "snow", "foreach", "reshape2", "survival", "randomForest")

p <- p[ ! p %in% installed.packages()]

print (p)

install.packages(p)