

require("h2o")
require("h2oEnsemble")
require("SuperLearner")
require("cvAUC")
require("parallel")

# preparing the data

dat <- read.csv("train.csv", header=TRUE)

# 
# and split it into a train and a test data set. The test dataset provided by the Kaggle challenge does not include output labels so we can not use it to test our machine learning model.
# 
# We split it by creating a train index that chooses 4000 line numbers from the data frame. We then subset it into train and test:

train_idx <- sample(1:nrow(dat),4000,replace=FALSE)
train <- dat[train_idx,] # select all these rows
test <- dat[-train_idx,] # select all but these rows

# starting h2o

localH2O = h2o.init(nthreads = 4)


training_frame <- as.h2o(localH2O, train)
validation_frame <- as.h2o(localH2O, test)
y <- "Choice"
x <- setdiff(names(training_frame), y)
family <- "binomial"
training_frame[,c(y)] <- as.factor(training_frame[,c(y)]) 
        #Force Binary classification
validation_frame[,c(y)] <- as.factor(validation_frame[,c(y)])
        # check to validate that this guarantees the same 0/1 mapping?

# Specify the base learner library & the metalearner
learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "SL.glm"

system.time (
        fit <- h2o.ensemble(x = x, y = y, 
                            training_frame = training_frame, 
                            family = family, 
                            learner = learner, 
                            metalearner = metalearner,
                            cvControl = list(V = 7, shuffle = TRUE),
                            parallel = "seq",
                            seed = 1234)
)

pred <- predict.h2o.ensemble(fit, validation_frame)
labels <- as.data.frame(validation_frame[,c(y)])[,1]

# Ensemble test AUC
AUC(predictions=as.data.frame(pred$pred)[,1], labels=labels)
# 0.870

L <- length(learner)
sapply(seq(L), function(l) AUC(predictions = as.data.frame(pred$basepred)[,l], labels = labels))
# [1] 0.8045044 0.8676948 0.8758433 0.8241745

# now deep!

system.time (
        #         deep <- h2o.deeplearning(x = x, y = y,
        #                                  training_frame = training_frame,
        #                                  activation = "RectifierWithDropout",
        #                                  epochs = 500,
        #                                  hidden = c(500, 500, 500),
        #                                  seed = 1234
        #                                  )
        deep <- h2o.deeplearning(x = x, y = y,
                                 epochs = 80,
                                 activation = "RectifierWithDropout",
                                 training_frame = training_frame,
                                 hidden = c(50, 50),
                                 seed = 1234)
)

pred.deep <- h2o.predict(deep, validation_frame)
labels.deep <- as.data.frame(validation_frame[,c(y)])[,1]
# Ensemble test AUC
AUC(predictions=as.data.frame(pred.deep$pred)[,1], labels=labels.deep)
# [1] 0.7340168
# [1] 0.7616866

g <- h2o.gbm(x, y,
             training_frame=training_frame,
             nfolds=7,
             ntrees=200, max_depth=3, learn_rate = 0.1,
             model_id="one_gbm")

pred.g <- h2o.predict(g, validation_frame)
AUC(predictions=as.data.frame(pred.g$pred)[,1], labels=labels)
# 0.7645
