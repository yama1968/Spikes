require(xgboost)
# load in the agaricus dataset
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
dtrain <- xgb.DMatrix(agaricus.train$data, label = agaricus.train$label)
dtest <- xgb.DMatrix(agaricus.test$data, label = agaricus.test$label)

param <- list(max.depth=2,eta=1,silent=1, objective="reg:linear")
nround = 2

# training the model for two rounds
bst = xgb.train(param, dtrain, nround, nthread = 2)
xgb.dump(bst, "xgboost.dumped.trees", with.stats=TRUE)

### predict using first full trees
ypred1 = predict(bst, dtest)

head(ypred1)

agaricus.test$data[2,c(29, 56, 60, 67, 109)]        

ypred2 = predict(bst, dtest, predleaf=TRUE)
head(ypred2)
