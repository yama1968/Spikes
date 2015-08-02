
p = (c("e1071", "Rcpp",
       "ggplot2", "reshape2", "caret", "extraTrees", "snow", "stringr", 
       "dclone", "rjags", "foreach",
       "devtools", "data.table", "dplyr", "Hmisc",
       "randomForestSRC", "survival"))

p = p[! p %in% installed.packages()]

install.packages(p)
