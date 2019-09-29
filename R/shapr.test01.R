library(MASS)
library(xgboost)
library(shapr)
library(data.table)
library(ggplot2)

data("Boston")

x_var <- c("lstat", "rm", "dis", "indus")
y_var <- "medv"

x_train <- as.matrix(Boston[-(1:6), x_var])
y_train <- Boston[-(1:6), y_var]
x_test <- as.matrix(Boston[1:6, x_var])

# Looking at the dependence between the features

cor(x_train)
#>            lstat         rm        dis      indus
#> lstat  1.0000000 -0.6108040 -0.4928126  0.5986263
#> rm    -0.6108040  1.0000000  0.1999130 -0.3870571
#> dis   -0.4928126  0.1999130  1.0000000 -0.7060903
#> indus  0.5986263 -0.3870571 -0.7060903  1.0000000

# Fitting a basic xgboost model to the training data
model <- xgboost(
  data = x_train,
  label = y_train,
  nround = 20,
  verbose = F
)


# Prepare the data for explanation
l <- prepare_kshap(
  Xtrain = x_train,
  Xtest = x_test
)

# Specifying the phi_0, i.e. the expected prediction without any features
pred_zero <- mean(y_train)

explainer <- shapr(x_train, model)

explanation <- explain(x = x_train, 
                       model = model, 
                       prediction_zero = pred_zero,
                       approach = "gaussian",
                       explainer)

# Printing the Shapley values for the test data
head(explanation$dt)
