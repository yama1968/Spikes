library(xgboost)
library(Ecdat)

# devtools::install_github("RSimran/RXGBfi")
library(RXGBfi)

data(Icecream)

train.data <- data.matrix(Icecream[,-1])
bst <- xgboost(data = train.data, label = Icecream$cons, max.depth = 3, eta = 1, nthread = 2, 
               nround = 2, objective = "reg:linear")
features <- names(Icecream[,-1])
xgb.fi(model = bst, features = features)
