library(caret)
library(PRROC)
library(dplyr)

set.seed(2969)

imbal_train <- twoClassSim(5000,
                           intercept = -25,
                           linearVars = 20,
                           noiseVars = 10)

imbal_test  <- twoClassSim(5000,
                           intercept = -25,
                           linearVars = 20,
                           noiseVars = 10)


auprcSummary <- function(data, lev = NULL, model = NULL){

  index_class2 <- data$obs == "Class2"
  index_class1 <- data$obs == "Class1"

  the_curve <- pr.curve(data$Class2[index_class2],
                        data$Class2[index_class1],
                        curve = FALSE)

  out <- the_curve$auc.integral
  names(out) <- "AUCPR"

  out

}


ctrl <- trainControl(method = "repeatedcv",
                     number = 2,
                     repeats = 5,
                     summaryFunction = auprcSummary,
                     classProbs = TRUE,
                     search = "random",
                     verboseIter = TRUE)

orig_pr <- train(Class ~ .,
                 data = imbal_train,
                 method = "gbm",
                 verbose = F,
                 metric = "AUCPR",
                 trControl = ctrl)

orig_pr

