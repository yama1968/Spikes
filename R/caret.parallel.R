library(doParallel);
cl <- makeCluster(detectCores())
registerDoParallel(cl)
library(caret)

tc <- trainControl(method="boot",number=25)
train(Species~.,data=iris,method="nnet",trControl=tc)
