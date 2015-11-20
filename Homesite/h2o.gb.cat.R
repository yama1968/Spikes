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

cat("assuming text variables are categorical and keeping them as factors!\n")
for (f in feature.names) {
    if (class(train[[f]]) == "character") {
        levels <- unique(c(train[[f]], test[[f]]))
#         train[[f]] <- as.integer(factor(train[[f]], levels=levels))
#         test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
        train[[f]] <- as.factor(train[[f]])
        test[[f]]  <- as.factor(test[[f]])
        
    }
}

cat("train data column names after slight feature engineering\n")
names(train)
cat("test data column names after slight feature engineering\n")
names(test)
tra <- train[,c(feature.names, "QuoteConversion_Flag")]

tra$QuoteConversion_Flag <- as.factor(tra$QuoteConversion_Flag)

nrow(train)
h <- sample(nrow(train),2000)

df.train <- tra[-h,]
df.val   <- tra[h,]

localH2O <- h2o.init(nthreads = -1)

train.hex <- as.h2o(localH2O, df.train, "Homesite.train")
val.hex <- as.h2o(localH2O, df.val, "Homesite.test")

system.time(
    model <- h2o.gbm(y                = "QuoteConversion_Flag", 
                     x                = names(df.train),
                     training_frame   = train.hex,
                     validation_frame = val.hex,
                     distribution     = "bernoulli",
                     max_depth        = 7,
                     ntrees           = 400,
                     learn_rate       = 0.02,
                     seed             = 1234)
)

print(model)

system.time(
    dl.grid <- h2o.deeplearning(y                = "QuoteConversion_Flag", 
                                x                = names(df.train),
                                training_frame   = train.hex,
                                validation_frame = val.hex,
                                hidden           = c(200, 200),
                                hidden_dropout_ratios = c(0.5, 0.5),
                                epochs           = 10,
                                activation       = "Rectifier")
)

print(dl.grid)

# pred1 <- predict(clf, data.matrix(test[,feature.names]))
# submission <- data.frame(QuoteNumber=test$QuoteNumber, QuoteConversion_Flag=pred1)
# cat("saving the submission file\n")
# write_csv(submission, "xgb1.csv")


