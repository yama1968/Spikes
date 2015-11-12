
library(doMC)
registerDoMC(cores = 4)

library(QSARdata)
library(caret)
data(Mutagen)

set.seed(4567)
inTraining <- createDataPartition(Mutagen_Outcome, p = .75, list = FALSE)
training_x <- Mutagen_Dragon[ inTraining,]
training_y <- Mutagen_Outcome[ inTraining]
testing_x  <- Mutagen_Dragon[-inTraining,]
testing_y  <- Mutagen_Outcome[-inTraining]

## Get rid of predictors that are very sparse
nzv <- nearZeroVar(training_x)
training_x <- training_x[, -nzv]
testing_x  <-  testing_x[, -nzv]

fitControl <- trainControl(method = "repeatedcv",
                           number = 7,
                           repeats = 1,
                           ## Estimate class probabilities
                           classProbs = TRUE,
                           ## Evaluate performance using 
                           ## the following function
                           summaryFunction = twoClassSummary)

set.seed(825)
system.time( svmFit <- train(x = training_x,
                             y = training_y,
                             method = "svmRadial",
                             trControl = fitControl,
                             preProc = c("center", "scale"),
                             tuneLength = 8,
                             metric = "ROC")
)
svmFit


fitControl2 <- trainControl(method = "adaptive_cv",
                            number = 7,
                            repeats = 1,
                            ## Estimate class probabilities
                            classProbs = TRUE,
                            ## Evaluate performance using 
                            ## the following function
                            summaryFunction = twoClassSummary,
                            ## Adaptive resampling information:
                            adaptive = list(min = 5,
                                            alpha = 0.05,
                                            method = "gls",
                                            complete = TRUE))

set.seed(825)
system.time (
    svmFit2 <- train(x = training_x,
                     y = training_y,
                     method = "svmRadial",
                     trControl = fitControl2,
                     preProc = c("center", "scale"),
                     tuneLength = 8,
                     metric = "ROC")
)
svmFit2

