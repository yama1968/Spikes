
library(caret)
library(xgboost)
library(dplyr)
library(PRROC)
library(xrf)

library(doMC)
library(stringr)

library(testthat)

registerDoMC(cores = detectCores(logical = FALSE))

# grabbing data from uci
census_income <- read.csv("../data/adult.data", header = FALSE, stringsAsFactors = FALSE)
colnames(census_income) <- c('age', 'workclass', 'fnlwgt', 'education', 'education_num', 'marital_status',
                             'occupation', 'relationship', 'race', 'sex', 'capital_gain', 'capital_loss',
                             'hours_per_week', 'native_country', 'above_50k')

inTrain <- createDataPartition(census_income$above_50k, p = 0.7, list = FALSE)
y_train <- census_income[inTrain, "above_50k"]
y_test <- census_income[-inTrain, "above_50k"]
neg <- " <=50K"
pos <- " >50K"


test_xrf <- function(clf) {

  y_test_xrf <- predict(clf, census_income[-inTrain,], type = 'response')
  pr_xrf <- pr.curve(y_test_xrf[y_test == pos], y_test_xrf[y_test == neg], curve = TRUE)

  plot(pr_xrf)
  pr_xrf
}

set.seed(42)
m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 10, max_depth = 2))


test_that("pr is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE))
})
##

set.seed(42)
m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 20,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                nfolds = 5,
                                pmax = 25))
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)

test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 25", {
  expect_that((coefs %>% nrow) < 25, equals(TRUE), info = "coefs")
})

dm <- model.matrix(m_xrf, census_income)
dm["(Intercept)"] <- 1

the_term <- coefs$term
dm <- dm[,(str_split_fixed(coefs$term, " ", 2)[,1])]

test_that("design matrix correct width", {
  expect_that((ncol(dm) == length(coefs$term)), equals(TRUE), info = "ncols")
})
test_that("design matrix correct nrow", {
  expect_that((nrow(dm) == nrow(census_income)), equals(TRUE), info = "nrows")
})

##
set.seed(42)
m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 20,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                nfolds = 5,
                                pmax = 25))
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)

test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 20", {
  expect_that((coefs %>% nrow) < 25, equals(TRUE), info = "coefs")
})
test_that("intercept",
          expect_that("(Intercept)" %in% coefs$term, equals(TRUE)) )

###

##

balance <- mean(y_train == pos)

test_that("balance right",
          expect_that(balance < 0.3, equals(TRUE)))

set.seed(42)
m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 20,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                nfolds = 5,
                                pmax = 25,
                                weights = ifelse(y_train == pos, 1 / sqrt(balance), 1)))
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)

test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 20", {
  expect_that((coefs %>% nrow) < 25, equals(TRUE), info = "coefs")
})

#
set.seed(42)
m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 20,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                nfolds = 5,
                                pmax = 25,
                                intercept = FALSE))
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)

test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 20", {
  expect_that((coefs %>% nrow) < 25, equals(TRUE), info = "coefs")
})
test_that("intercept",
          expect_that("(Intercept)" %in% coefs$term, equals(FALSE)) )

#
set.seed(42)

foldid <- createFolds(y_train, k = 10, list = FALSE)

m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 40,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                foldid = foldid,
                                nlambda = 200,
                                pmax = 50))
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)
test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 50", {
  expect_that((coefs %>% nrow) < 50, equals(TRUE), info = "coefs")
})

###

set.seed(42)

foldid <- createFolds(y_train, k = 10, list = FALSE)

m_xrf <- xrf(above_50k ~ ., census_income[inTrain,], family = 'binomial',
             xgb_control = list(nrounds = 40,
                                max_depth = 2,
                                eval_metric = "aucpr"),
             glm_control = list(type.measure = 'auc',
                                foldid = foldid,
                                nlambda = 200,
                                pmax = 50),
             deoverlap = TRUE)
coefs <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)
test_that("pr2 is reasonable", {
  pr <- test_xrf(m_xrf)
  expect_that(pr$auc.integral > 0.75, equals(TRUE), info = "pr")
})
test_that("coef < 50", {
  expect_that((coefs %>% nrow) < 50, equals(TRUE), info = "coefs")
})

