library(xgboost)

data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')

# Both dataset are list with two items, a sparse matrix and labels
# (labels = outcome column which will be learned).
# Each column of the sparse Matrix is a feature in one hot encoding format.
train <- agaricus.train
test <- agaricus.test

dtrain <- xgb.DMatrix(data   = train$data, 
                      label  = train$label)
dtest  <- xgb.DMatrix(data   = test$data, 
                      label  = test$label)
watchlist <- list(train = dtrain,
                  test  = dtest)

params <- list(max.depth = 1,
               eta = 1, 
               nthread = 2, 
               nround = 2,
               objective = "binary:logistic")

set.seed(1234)
bst <- xgb.train(data         = dtrain, 
                 params       = params,
                 watchlist    = watchlist,
                 eval.metric  = "auc",
                 nrounds      = 4)


# train$data@Dimnames[[2]] represents the column names of the sparse matrix.
xgb.importance(train$data@Dimnames[[2]], model = bst)


# Same thing with co-occurence computation this time
importanceRaw <- xgb.importance(train$data@Dimnames[[2]], model = bst, data = train$data, label = train$label)
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]
as.data.frame(importanceClean)


library(xgboostExplainer)

explainer = buildExplainer(bst, dtrain, type = "binary")
pred.breakdown <- explainPredictions(bst, explainer, dtest)

showWaterfall(bst, explainer, dtest, test$data, 2, type = "binary")
showWaterfall(bst, explainer, dtest, test$data, 98, type = "binary")

params$max.depth = 3

new <- xgb.train(data         = dtrain, 
                 xgb_model    = bst,
                 params       = params,
                 watchlist    = watchlist,
                 eval.metric  = "auc",
                 nrounds      = 4)

xgb.importance(train$data@Dimnames[[2]], model = new)

importanceRaw <- xgb.importance(train$data@Dimnames[[2]], model = new, data = train$data, label = train$label)
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequency=NULL)]
as.data.frame(importanceClean)
