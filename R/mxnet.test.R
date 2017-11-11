# http://dmlc.ml/rstats/2015/11/03/training-deep-net-with-R.html

require(mlbench)

## Loading required package: mlbench

require(mxnet)
library(caret)

## Loading required package: mxnet
## Loading required package: methods

data(Sonar, package="mlbench")

Sonar[,61] = as.numeric(Sonar[,61])-1
train.ind = c(1:50, 100:150)
train.x = data.matrix(Sonar[train.ind, 1:60])
train.y = Sonar[train.ind, 61]
test.x = data.matrix(Sonar[-train.ind, 1:60])
test.y = Sonar[-train.ind, 61]

mx.set.seed(0)
model <- mx.mlp(train.x, train.y, hidden_node=10, out_node=2, out_activation="softmax",
                num.round=40, array.batch.size=15, learning.rate=0.06,
                optimizer="adagrad",
                eval.metric=mx.metric.accuracy,
                ctx = mx.gpu())

preds = predict(model, test.x)

## Auto detect layout of input matrix, use rowmajor..

pred.label = max.col(t(preds))-1
table(pred.label, test.y)

# on mnist

mnist <- "/home4/2015/home2/yannick2/DataScience2/kaggle_mnist/"

train <- read.csv(paste0(mnist, 'train.csv'), header = TRUE)
test <- read.csv(paste0(mnist,'test.csv'), header = TRUE)

train.x <- train[,-1]
train.y <- train[,1]

train.x <- (train.x/255)
test <- (test/255)

train.filter <- createDataPartition(train.y, p = 0.7, list = FALSE)
valid.x <- train.x[-train.filter,]
valid.y <- train.y[-train.filter]
train.x <- train.x[train.filter,]
train.y <- train.y[train.filter]

data <- mx.symbol.Variable("data")
fc1 <- mx.symbol.FullyConnected(data, name="fc1", num_hidden=128)
act1 <- mx.symbol.Activation(fc1, name="relu1", act_type="relu")
fc2 <- mx.symbol.FullyConnected(act1, name="fc2", num_hidden=64)
act2 <- mx.symbol.Activation(fc2, name="relu2", act_type="relu")
fc3 <- mx.symbol.FullyConnected(act2, name="fc3", num_hidden=10)
softmax <- mx.symbol.SoftmaxOutput(fc3, name="sm")

get.mnist.mlp <- function() {
  mx.set.seed(1234)

  model <- mx.model.FeedForward.create(softmax, X=data.matrix(train.x), y=train.y,
                                       ctx=devices, num.round=12, array.batch.size=128,
                                       learning.rate=0.03, momentum=0.8,  eval.metric=mx.metric.accuracy,
                                       initializer=mx.init.uniform(0.07),
                                       epoch.end.callback=mx.callback.log.train.metric(100),
                                       array.layout = "rowmajor")

  model
}

devices <- mx.cpu()
system.time( m1 <- get.mnist.mlp())

devices <- mx.gpu()
system.time( m2 <- get.mnist.mlp())

valid.pred <- predict(m2, data.matrix(valid.x), array.layout = "rowmajor")
valid.pred <- apply(valid.pred, 2, which.max) - 1

print(mean(valid.y == valid.pred))
table(valid.pred, valid.y)

## lenet

# input
data <- mx.symbol.Variable('data')
# first conv
conv1 <- mx.symbol.Convolution(data=data, kernel=c(5,5), num_filter=20)
tanh1 <- mx.symbol.Activation(data=conv1, act_type="tanh")
pool1 <- mx.symbol.Pooling(data=tanh1, pool_type="max",
                           kernel=c(2,2), stride=c(2,2))
# second conv
conv2 <- mx.symbol.Convolution(data=pool1, kernel=c(5,5), num_filter=50)
tanh2 <- mx.symbol.Activation(data=conv2, act_type="tanh")
pool2 <- mx.symbol.Pooling(data=tanh2, pool_type="max",
                           kernel=c(2,2), stride=c(2,2))
# first fullc
flatten <- mx.symbol.Flatten(data=pool2)
fc1 <- mx.symbol.FullyConnected(data=flatten, num_hidden=500)
tanh3 <- mx.symbol.Activation(data=fc1, act_type="tanh")
# second fullc
fc2 <- mx.symbol.FullyConnected(data=tanh3, num_hidden=10)
# loss
lenet <- mx.symbol.SoftmaxOutput(data=fc2)

train.array <- t(train.x)
dim(train.array) <- c(28, 28, 1, nrow(train.x))
test.array <- t(test)
dim(test.array) <- c(28, 28, 1, nrow(test))

valid.array <- t(valid.x)
dim(valid.array) <- c(28, 28, 1, nrow(valid.x))

n.gpu <- 1
device.cpu <- mx.cpu()
device.gpu <- lapply(0:(n.gpu-1), function(i) {
  mx.gpu(i)
})

mx.set.seed(0)
tic <- proc.time()
model <- mx.model.FeedForward.create(lenet, X=train.array, y=train.y,
                                     ctx=device.cpu, num.round=1, array.batch.size=100,
                                     learning.rate=0.05, momentum=0.9, wd=0.00001,
                                     eval.metric=mx.metric.accuracy,
                                     epoch.end.callback=mx.callback.log.train.metric(100))
print(proc.time() - tic)

mx.set.seed(0)
tic <- proc.time()
model <- mx.model.FeedForward.create(lenet, X = train.array, y = train.y,
                                     ctx = device.gpu, num.round = 100, array.batch.size = 100,
                                     #learning.rate = 0.009, momentum = 0.95, wd = 0.0001,
                                     learning.rate = 0.009, momentum = 0.97, wd = 0.0001,
                                     eval.metric = mx.metric.accuracy,
                                     epoch.end.callback = mx.callback.log.train.metric(100),
                                     eval.data = list(data = valid.array, label = valid.y))
print(proc.time() - tic)

preds <- predict(model, ctx=mx.gpu(0), valid.array)
pred.label <- max.col(t(preds)) - 1
print(mean(valid.y == pred.label))
#
# 47] Validation-accuracy=0.99968253968254
# [48] Train-accuracy=0.999642857142857
# [48] Validation-accuracy=0.999761904761905
# [49] Train-accuracy=0.999666666666667
# [49] Validation-accuracy=0.999761904761905
# [50] Train-accuracy=0.999714285714286
# [50] Validation-accuracy=0.999761904761905
# > print(proc.time() - tic)
# utilisateur     système      écoulé
# 195.044      17.104     100.601
# > preds <- predict(model, ctx=mx.gpu(0), valid.array)
# > pred.label <- max.col(t(preds)) - 1
# > print(mean(valid.y == pred.label))
# [1] 0.9997618


mx.set.seed(0)
tic <- proc.time()
model <- mx.model.FeedForward.create(lenet, X=train.array, y=train.y,
                                     ctx=device.gpu, num.round=12, array.batch.size=256,
                                     optimizer = "adam",
                                     eval.metric=mx.metric.accuracy,
                                     epoch.end.callback=mx.callback.log.train.metric(128))
print(proc.time() - tic)
