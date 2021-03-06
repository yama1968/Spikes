
library(RCurl)
library(xrf)
library(mgcv)

# grabbing data from uci
census_income_text <- getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data')
census_income <- read.csv(textConnection(census_income_text), header = F, stringsAsFactors = F)
colnames(census_income) <- c('age', 'workclass', 'fnlwgt', 'education', 'education_num', 'marital_status',
                             'occupation', 'relationship', 'race', 'sex', 'capital_gain', 'capital_loss',
                             'hours_per_week', 'native_country', 'above_50k')

m_xrf <- xrf(above_50k ~ ., census_income, family = 'binomial',
             xgb_control = list(nrounds = 100, max_depth = 3))


library(dplyr)
library(pre)
library(glmnet)
x <- library(xgboost)

auc <- function(prediction, actual) {
  stopifnot(length(unique(actual)) == 2)
  stopifnot(length(prediction) == length(actual))
  mann_whit <- wilcox.test(prediction ~ actual)$statistic
  unname(1 - mann_whit/(sum(actual) * as.double(sum(!actual))))
}

census_income <- census_income %>%
  # pre is picky about data types
  mutate_if(is.character, as.factor) %>%
  mutate(
    above_50k = as.character(above_50k) == ' >50K'
  )

set.seed(55455)
train_ix <- sample(nrow(census_income), floor(nrow(census_income) * .66))
census_train <- census_income[train_ix, ]
census_test <- census_income[-train_ix, ]
census_mat <- model.matrix(above_50k ~ ., census_income)
census_train_mat <- census_mat[train_ix, ]
census_test_mat <- census_mat[-train_ix, ]

system.time(m_pre <- pre(above_50k ~ ., na.omit(census_train),
                         family = 'binomial', ntrees = 100, maxdepth = 3, tree.unbiased = TRUE))
system.time(m_xrf <- xrf(above_50k ~ ., census_train, family = 'binomial',
                         xgb_control = list(nrounds = 100, max_depth = 3)))
m_xgb <- xgboost(census_train_mat, census_train$above_50k, max_depth = 3, nrounds = 100, objective = 'binary:logistic')
m_glm <- cv.glmnet(census_train_mat, census_train$above_50k, alpha = 1)

auc(predict(m_pre, census_test), census_test$above_50k)
auc(predict(m_xrf, census_test), census_test$above_50k)
auc(predict(m_glm, newx = census_test_mat, s = 'lambda.min'), census_test$above_50k)
auc(predict(m_xgb, newdata = census_test_mat, s = 'lambda.min'), census_test$above_50k)

system.time({
m_gam <- gam(above_50k ~ s(age) + workclass + s(fnlwgt) + education + education_num + marital_status +
               occupation + relationship + race + sex +
               s(capital_gain) + s(capital_loss, k = 3) + s(hours_per_week),
             data = census_train,
             family = 'binomial',
             select = T,
             method = "REML")
})

u <- par(mfrow = c(3,2))
plot(m_gam)
par(mfrow = u)

auc(predict(m_gam, census_test), census_test$above_50k)


