
library(RCurl)
library(xrf)
library(dplyr)
library(glmnet)
library(xgboost)
library(PRROC)

# grabbing data from uci
# census_income_text <- getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data')
# census_income <- read.csv(textConnection(census_income_text), header=F, stringsAsFactors = F)

census_income <- read.csv("../data/adult.data", header = F, stringsAsFactors = F)

colnames(census_income) <- c('age', 'workclass', 'fnlwgt', 'education', 'education_num', 'marital_status',
                             'occupation', 'relationship', 'race', 'sex', 'capital_gain', 'capital_loss',
                             'hours_per_week', 'native_country', 'above_50k')


census_income <- census_income %>%
  # pre is picky about data types
  mutate_if(is.character, as.factor) %>%
  mutate(
    above_50k = as.character(above_50k) == ' >50K'
  )

set.seed(55455)
train_ix <- sample(nrow(census_income), floor(nrow(census_income) * .7))
train <- census_income[train_ix, ]
test <- census_income[-train_ix, ]
census_mat <- model.matrix(above_50k ~ ., census_income)
train_mat <- census_mat[train_ix, ]
test_mat <- census_mat[-train_ix, ]

# training xgb

xgb_control = list(max_depth = 1,
                   base_score = 0.5,
                   colsample_bytree = 0.4,
                   gamma = 0.4,
                   # learning_rate = 0.08,
                   learning_rate = 0.4,
                   reg_alpha = 0.1,
                   reg_lambda = 0.1,
                   subsample = 0.65,
                   objective = 'binary:logistic',
                   eval_metric = 'aucpr',
                   # tree_method = 'gpu_hist',
                   seed = 1)

dtrain <- xgb.DMatrix(train_mat, label = train$above_50k)
dtest <- xgb.DMatrix(test_mat, label = test$above_50k)


xgb <- xgb.train(xgb_control,
                 dtrain,
                 watchlist = list(train = dtrain, eval = dtest),
                 # nrounds = 961,
                 nrounds = 41,
                 print_every_n = 40)

xgb_control$max_depth <- 2

xgb <- xgb.train(xgb_control,
                 dtrain,
                 xgb_model = xgb,
                 watchlist = list(train = dtrain, eval = dtest),
                 # nrounds = 961,
                 nrounds = 81,
                 print_every_n = 40)

xgb_control$max_depth <- 3

xgb <- xgb.train(xgb_control,
                 dtrain,
                 xgb_model = xgb,
                 watchlist = list(train = dtrain, eval = dtest),
                 # nrounds = 961,
                 nrounds = 41,
                 print_every_n = 40)


y_test_xgb <- predict(xgb, test_mat, type = 'prob')
pr_xgb <- pr.curve(y_test_xgb[test$above_50k == 1], y_test_xgb[test$above_50k == 0], curve = TRUE)
print(paste("pr xgb =", pr_xgb$auc.integral))

roc_xgb <- roc.curve(y_test_xgb[test$above_50k == 1], y_test_xgb[test$above_50k == 0], curve = TRUE)
print(paste("roc xgb =", roc_xgb$auc))

# and then xrf

avg_pos <- mean(train$above_50k)

glm_control <- list(type.measure = "auc",
                    pmax = 80,
                    parallel = T,
                    nfolds = 3)

m_xrf <- xrf(above_50k ~ .,
             data = train,
             prefit_xgb = xgb,
             glm_control = glm_control,
             sparse = F,
             family = "binomial",
             deoverlap = T)

y_test_xrf <- predict(m_xrf, test, type = 'response', sparse = F)
pr_xrf <- pr.curve(y_test_xrf[test$above_50k == 1], y_test_xrf[test$above_50k == 0], curve = TRUE)
print(paste("pr xrf =", pr_xrf$auc.integral))

roc_xrf <- roc.curve(y_test_xrf[test$above_50k == 1], y_test_xrf[test$above_50k == 0], curve = TRUE)
print(paste("roc xrf =", roc_xrf$auc))

coefs_xrf <- coef(m_xrf) %>% filter(coefficient_lambda.min != 0)
coefs_xrf %>% View

