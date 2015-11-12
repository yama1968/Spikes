library(doParallel);
cl <- makeCluster(detectCores())
registerDoParallel(cl)
library(caret)

tc <- trainControl(method="boot",number=25)
train(Species~.,data=iris,method="nnet",trControl=tc)

stopCluster(cl)

library(doMC)
registerDoMC(cores = 5)
## All subsequent models are then run in parallel
model <- train(y ~ ., data = iris, method = "rf")

