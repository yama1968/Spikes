
library(xrf)
library(caret)
library(dplyr)
library(PRROC)
library(xgboost)

df <- read.csv("../dataset/compas.csv") %>% as_tibble

set.seed(42)
inTrain <- createDataPartition(df$Recidivate.Within.Two.Years, p = 0.6, list = FALSE)

train <- df[inTrain,]
test <- df[-inTrain,]

y <- train$Recidivate.Within.Two.Years

prop <- 1 / mean(y)
weights <- ifelse(y, prop, 1)

y_test <- test$Recidivate.Within.Two.Years

glm_control <- list(type.measure = "auc",
                    nfolds = 3,
                    pmax = 120,
                    parallel = T)

xgb_control = list(nrounds = 40, colsample_bytree = 0.6, gamma = 11,
                   learning_rate = 0.1, max_depth = 6, reg_alpha = 0.76, reg_lambda = 0.21, subsample = 0.5,
                   eval_metric = 'aucpr')

clf <- xrf(Recidivate.Within.Two.Years ~ .,
           data = train,
           glm_control = glm_control,
           family = "binomial",
           xgb_control = xgb_control,
           sparse = FALSE)

clf %>% coef %>% filter(coefficient_lambda.min != 0) %>% View

y_hat <- predict(clf, test, type = "response")

table(y_hat > 0.5, y_test)
print(mean((y_hat >= 0.5) == y_test))

pr <- pr.curve(y_hat[y_test == 1], y_hat[y_test == 0], curve = TRUE)

pr$auc.integral
plot(pr)

test_pmax <- function(pmax) {
  glm_control$pmax <- pmax
  clf <- xrf(Recidivate.Within.Two.Years ~ .,
             data = train,
             glm_control = glm_control,
             family = "binomial",
             xgb_control = xgb_control,
             sparse = FALSE)
  y_hat <- predict(clf, test, type = "response")
  c(mean((y_hat >= 0.5) == y_test),
    clf %>% coef %>% filter(coefficient_lambda.min != 0) %>% count %>% as.numeric,
    pr.curve(y_hat[y_test == 1], y_hat[y_test == 0], curve = TRUE)$auc.integral)
}

r <- foreach(pmax = c(5, 10, 15, 20, 30, 40, 60, 80, 100, 120, 140, 160, 200, 1000), .combine = rbind) %dopar%
  c(pmax, test_pmax(pmax))
colnames(r) <- c("pmax", "acc", "non_null", "pr")
