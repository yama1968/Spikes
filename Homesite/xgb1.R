# Based on Ben Hamner script from Springleaf
# https://www.kaggle.com/benhamner/springleaf-marketing-response/random-forest-example

library(readr)
library(xgboost)

#my favorite seed^^

cat("reading the train and test data\n")
train <- read_csv("../data/train.csv")
test  <- read_csv("../data/test.csv")

# There are some NAs in the integer columns so conversion to zero
train[is.na(train)]   <- 0
test[is.na(test)]   <- 0

cat("train data column names and details\n")
names(train)
str(train)
summary(train)
cat("test data column names and details\n")
names(test)
str(test)
summary(test)


# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]


feature.names <- names(train)[c(3:48,50:75,77:81,83,85:89,94:98,100:103,105,106,109:198,200:301)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
    if (class(train[[f]])=="character") {
        levels <- unique(c(train[[f]], test[[f]]))
        train[[f]] <- as.integer(factor(train[[f]], levels=levels))
        test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
    }
}

cat("train data column names after slight feature engineering\n")
names(train)
cat("test data column names after slight feature engineering\n")
names(test)
tra<-train[,feature.names]

nrow(train)
h<-sample(nrow(train),2000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),label=train$QuoteConversion_Flag[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),label=train$QuoteConversion_Flag[-h])

watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "binary:logistic", 
                booster             = "gbtree",
                eta                 = 0.020, # 0.06, #0.01,
                max_depth           = 7, #changed from default of 8
                subsample           = 0.82, # 0.7
                colsample_bytree    = 0.66, # 0.7
                eval_metric         = "auc"
                #num_parallel_tree   = 2
                # alpha = 0.0001, 
                # lambda = 1
)

system.time (
    clf <- xgb.train(   params              = param, 
                        data                = dtrain, 
                        nrounds             = 400, # 1800 #300, #280, #125, #250, # changed from 300
                        verbose             = 0,
                        early.stop.round    = 700,
                        watchlist           = watchlist,
                        maximize            = FALSE
    )
)

pred1 <- predict(clf, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, QuoteConversion_Flag=pred1)
# cat("saving the submission file\n")
# write_csv(submission, "xgb1.csv")


