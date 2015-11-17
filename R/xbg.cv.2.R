require(xgboost)
require(Matrix)
if (!require(vcd)) {
  install.packages('vcd') #Available in Cran. Used for its dataset with categorical values.
  require(vcd)
}

data(Arthritis)

df <- Arthritis
df$AgeFactor <- as.factor(10 * (df$Age %/% 10))

X <- sparse.model.matrix(Improved~.-1-Age-ID, data = df)
y <- df$Improved == "Marked"

params = list(max.depth = 3,
              eta = 0.1, nthread = 2, objective = "binary:logistic")

set.seed(1234)
cv <- xgb.cv(params   = params,
             nrounds  = 8,
             data     = X, 
             label    = y,
             metrics  = list("auc"),
             nfold    = 7)

train <- xgb.DMatrix(data = X, label = y)
watchlist <- list(train = train, test = train)

bst <- xgb.train(data         = train, 
                 params       = params,
                 watchlist    = watchlist,
                 eval.metric  = "auc",
                 nrounds      = 8)

xgb.importance(feature_names = colnames(X), model = bst)
