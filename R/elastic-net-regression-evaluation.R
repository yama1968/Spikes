#!/usr/bin/Rscript --vanilla

###########################################################
##                                                       ##
##   elastic.R                                           ##
##                                                       ##
##                Author: Tony Fischetti                 ##
##                        tony.fischetti@gmail.com       ##
##                                                       ##
###########################################################

# workspace cleanup
rm(list=ls())

# options
options(echo=TRUE)
options(stringsAsFactors=FALSE)

# cli args
args <- commandArgs(trailingOnly=TRUE)

# libraries
library(dplyr)
library(magrittr)
library(assertr)
library(tidyr)
library(ggplot2)
library(car)

library(glmnet)
library(boot)

library(gridExtra)


# 32x10
# mean vif: 9.577414
X <- model.matrix(mpg ~ ., data=mtcars)[,-1]
y <- mtcars$mpg

alphas <- seq(0, 1, by=.002)
mses <- numeric(501)
mins <- numeric(501)
maxes <- numeric(501)

require(doMC)
registerDoMC(cores=4)

for(i in 1:501){
  cvfits <- cv.glmnet(X, y, alpha=alphas[i], nfolds=32, parallel=TRUE)
  loc <- which(cvfits$lambda==cvfits$lambda.min)
  maxes[i] <- cvfits$lambda %>% max
  mins[i] <- cvfits$lambda %>% min
  mses[i] <- cvfits$cvm[loc]
}

this <- data.frame(mse=mses, alpha=alphas)

plot1 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  #geom_smooth() +
  ylab("LOOCV mean squared error") +
  xlab("alpha parameter") +
  ggtitle("model error of highest performing regularized elastic-net
          regression as a function of alpha parameter
          <using mtcars predicting mpg>")


# kitchen.sink <- glm(mpg ~ ., data=mtcars)
# cv.glm(mtcars, kitchen.sink)  # 12.02194

errors <- numeric(nrow(mtcars))
for(i in 1:nrow(mtcars)){
  train <- mtcars[-i,]
  test <- mtcars[i,]
  kitchen.sink <- glm(mpg ~ ., data=train)
  the.pred <- predict(kitchen.sink, newdata=test)
  errors[i] <- (the.pred - test$mpg)^2
}
mean(errors)     # 12.18156



full <- glm(mpg ~ ., data=mtcars)
stepped <- step(full, direction = "both")
sub.coeffs <- names(stepped$coefficients[-1])

errors <- numeric(nrow(mtcars))
for(i in 1:nrow(mtcars)){
  train <- mtcars[-i,]
  test <- mtcars[i,]
  new.feat.sub <- train[, sub.coeffs]
  new.feat.sub$mpg <- train$mpg
  mod <- glm(mpg ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$mpg)^2
}
mean(errors)     # 7.228

# substantial variation in selected features
errors <- numeric(nrow(mtcars))
for(i in 1:nrow(mtcars)){
  train <- mtcars[-i,]
  test <- mtcars[i,]
  smaller <- glm(mpg ~ ., data=train)
  stepped <- step(smaller, direction="both", trace=0)
  new.feat.sub <- train[, names(stepped$coefficients[-1])]
  print(names(stepped$coefficients[-1]))
  new.feat.sub$mpg <- train$mpg
  mod <- glm(mpg ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$mpg)^2
}
mean(errors)    # 13.27429


other.errors <- data.frame(method=c("kitchen sink",
                                    "bad stepwise est.",
                                    "better stepwise est."),
                           errors=c(12.18156, 7.228, 13.27429))

plot2 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  #geom_smooth() +
  ylab("LOOCV mean squared error") +
  xlab("alpha parameter") +
  ggtitle("[with kitchen sink and stepwise LOOCV MSEs]") +
  geom_hline(aes(yintercept=errors,
                 color=method, group=method),
             size=2, data=other.errors, show_guide=TRUE)


grid.arrange(plot1, plot2, ncol=2)


#--------------------------------------#
#--------------------------------------#
#--------------------------------------#

# 517 x 11
# mean VIF: 1.727451
fires <- read.csv("./forestfires.csv")
fires$month <- NULL
fires$area <- log(fires$area+1)



X <- model.matrix(area ~ ., data=fires)[,-1]
y <- fires$area

alphas <- seq(0.0, 1, by=.01)
mses <- numeric(101)
mins <- numeric(101)
maxes <- numeric(101)



for(i in 1:101){
  cvfits <- cv.glmnet(X, y, alpha=alphas[i], nfolds=400, parallel=TRUE)
  loc <- which(cvfits$lambda==cvfits$lambda.min)
  maxes[i] <- cvfits$lambda %>% max
  mins[i] <- cvfits$lambda %>% min
  mses[i] <- cvfits$cvm[loc]
}

this <- data.frame(mse=mses, alpha=alphas)

plot1 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  geom_smooth() +
  ylab("400-fold cross validation mean squared error") +
  xlab("alpha parameter") +
  ggtitle("model error of highest performing regularized
          elastic-net regression as a function of alpha parameter
          <using forest fire data>")



# kitchen.sink <- glm(area ~ ., data=fires)
# cv.glm(fires, kitchen.sink)$delta[2]   # 2.131694
# 
# step(kitchen.sink, direction="both") # 4 variables
# stepped <- glm(area ~ X + DMC + RH + wind, data=fires)
# cv.glm(fires, stepped)  # 1.951653
# 



errors <- numeric(nrow(fires))
for(i in 1:nrow(fires)){
  train <- fires[-i,]
  test <- fires[i,]
  kitchen.sink <- glm(area ~ ., data=train)
  the.pred <- predict(kitchen.sink, newdata=test)
  errors[i] <- (the.pred - test$area)^2
}
mean(errors)     # 2.132028


full <- glm(area ~ ., data=fires)
stepped <- step(full, direction = "both")
sub.coeffs <- names(stepped$coefficients[-1])

errors <- numeric(nrow(fires))
for(i in 1:nrow(fires)){
  train <- fires[-i,]
  test <- fires[i,]
  new.feat.sub <- train[, sub.coeffs]
  new.feat.sub$area <- train$area
  mod <- glm(area ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$area)^2
}
mean(errors)     # 1.951689


# much less variation in selected features
errors <- numeric(nrow(fires))
for(i in 1:nrow(fires)){
  train <- fires[-i,]
  test <- fires[i,]
  smaller <- glm(area ~ ., data=train)
  stepped <- step(smaller, direction="both", trace=0)
  new.feat.sub <- train[, names(stepped$coefficients[-1])]
  print(names(stepped$coefficients[-1]))
  new.feat.sub$area <- train$area
  mod <- glm(area ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$area)^2
}
mean(errors)    # 2.151955


other.errors <- data.frame(method=c("kitchen sink",
                                    "bad stepwise est.",
                                    "better stepwise est."),
                           errors=c(2.132028, 1.951689, 2.151955))

plot2 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  geom_smooth() +
  ylab("400-fold cross validation mean squared error") +
  xlab("alpha parameter") +
  ggtitle("[with kitchen sink and stepwise LOOCV MSEs]") +
  geom_hline(aes(yintercept=errors,
                 color=method, group=method),
             size=2, data=other.errors, show_guide=TRUE)

plot2 <- plot2 + ylab("400-fold cross validation mean squared error")


grid.arrange(plot1, plot2, ncol=2)

#--------------------------------------#
#--------------------------------------#
#--------------------------------------#

# 100x20
# mean vif: 1.225789
data(QuickStartExample)
X <- x

mock.frame <- data.frame(X)
mock.frame$target <- y


alphas <- seq(0, 1, by=.002)
mses <- numeric(501)
mins <- numeric(501)
maxes <- numeric(501)


for(i in 1:501){
  cvfits <- cv.glmnet(X, y, alpha=alphas[i], nfolds=100)
  loc <- which(cvfits$lambda==cvfits$lambda.min)
  maxes[i] <- cvfits$lambda %>% max
  mins[i] <- cvfits$lambda %>% min
  mses[i] <- cvfits$cvm[loc]
}

this <- data.frame(mse=mses, alpha=alphas)

plot1 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  #geom_smooth() +
  ylab("LOOCV mean squared error") +
  xlab("alpha parameter") +
  ggtitle("model error of highest performing regularized
          elastic-net regression as a function of alpha parameter
          <'quickstart' glmnet data>")



# kitchen.sink <- glm(target ~ ., data=mock.frame)
# cv.glm(mock.frame, kitchen.sink)$delta[2]   # 1.142114
# 
# step(kitchen.sink, direction="both") # 8 variables
# stepped <- glm(target ~ X1 + X3 + X5 + X6 + X8 + X11 + X14 + X20, data=mock.frame)
# cv.glm(mock.frame, stepped)  # 0.9433261


errors <- numeric(nrow(mock.frame))
for(i in 1:nrow(mock.frame)){
  train <- mock.frame[-i,]
  test <- mock.frame[i,]
  kitchen.sink <- glm(target ~ ., data=train)
  the.pred <- predict(kitchen.sink, newdata=test)
  errors[i] <- (the.pred - test$target)^2
}
mean(errors)     # 1.144384


full <- glm(target ~ ., data=mock.frame)
stepped <- step(full, direction = "both")
sub.coeffs <- names(stepped$coefficients[-1])

errors <- numeric(nrow(mock.frame))
for(i in 1:nrow(mock.frame)){
  train <- mock.frame[-i,]
  test <- mock.frame[i,]
  new.feat.sub <- train[, sub.coeffs]
  new.feat.sub$target <- train$target
  mod <- glm(target ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$target)^2
}
mean(errors)     # 0.9441541


# virtually no variation in selected features
errors <- numeric(nrow(mock.frame))
for(i in 1:nrow(mock.frame)){
  train <- mock.frame[-i,]
  test <- mock.frame[i,]
  smaller <- glm(target ~ ., data=train)
  stepped <- step(smaller, direction="both", trace=0)
  new.feat.sub <- train[, names(stepped$coefficients[-1])]
  print(names(stepped$coefficients[-1]))
  new.feat.sub$target <- train$target
  mod <- glm(target ~ ., data=new.feat.sub)
  the.pred <- predict(mod, newdata=test)
  errors[i] <- (the.pred - test$target)^2
}
mean(errors)    # 0.9544712



other.errors <- data.frame(method=c("kitchen sink",
                                    "bad stepwise est.",
                                    "better stepwise est."),
                           errors=c(1.144384, 0.9441541, 0.9544712))

plot2 <- ggplot(this, aes(x=alpha, y=mse)) +
  geom_point(shape=1) +
  #geom_smooth() +
  ylab("LOOCV mean squared error") +
  xlab("alpha parameter") +
  ggtitle("[with kitchen sink and stepwise LOOCV MSEs]") +
  geom_hline(aes(yintercept=errors,
                 color=method, group=method),
             size=2, data=other.errors, show_guide=TRUE)


grid.arrange(plot1, plot2, ncol=2)

