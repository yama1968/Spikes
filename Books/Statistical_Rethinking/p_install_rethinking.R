#


p = c("coda", "mvtnorm", "devtools")


p <- p[ ! p %in% installed.packages()]

print(p)

install.packages(p)

library(devtools)

devtools::install_github("rmcelreath/rethinking")
