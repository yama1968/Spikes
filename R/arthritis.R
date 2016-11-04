
library(caret)
library(dplyr)
require(xgboost)
require(Matrix)
require(data.table)

library(doParallel)

if (!require(vcd)) {
  install.packages('vcd') #Available in Cran. Used for its dataset with categorical values.
  require(vcd)
}

k = 5
data("Arthritis")

set.seed(1234)

trControl <- trainControl(method = "cv",
                          number = 5)

rf <- train(Improved~.-ID,
            data = Arthritis,
            trControl = trControl,
            method = "rf",
            tuneLength = 10)
print(rf)

linear <- train(Improved~.-ID,
                data = Arthritis,
                trControl = trainControl("cv", 7, classProbs=TRUE),
                method = "glmnet",
                tuneLength = 20)
print (linear)

linear2 <- train(Improved~.-ID,
                data          = Arthritis,
                trControl     = trainControl("cv", 7, classProbs=TRUE),
                preProcess    = c("BoxCox", "center", "scale"),
                method        = "glmnet",
                tuneLength    = 10)
print (linear2)





