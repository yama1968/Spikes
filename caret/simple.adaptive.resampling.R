library(caret)

set.seed(1)
dat <- twoClassSim(100)
mod1 <- train(Class ~ ., data = dat, 
              method = "rf",
              preProc = c("center", "scale"),
              tuneLength = 20,
              trControl = trainControl(method = "adaptive_cv", 
                                       classProbs = TRUE,
                                       verboseIter = TRUE,
                                       adaptive = list(min = 5,
                                                       alpha = 0.05,
                                                       method = "BT",
                                                       complete = TRUE)))