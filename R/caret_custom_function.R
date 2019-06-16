library(caret)
library(MLmetrics)

set.seed(346)
dat <- twoClassSim(200)

## See http://topepo.github.io/caret/training.html#metrics
f1 <- function(data, lev = NULL, model = NULL) {
  f1_val <- F1_Score(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  c(F1 = f1_val)
}

set.seed(35)
mod <- train(Class ~ ., data = dat,
             method = "rpart",
             tuneLength = 5,
             metric = "F1",
             trControl = trainControl(summaryFunction = f1,
                                      classProbs = TRUE))
