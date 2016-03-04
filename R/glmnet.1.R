
library(glmnet)
library(dplyr)
library(caret)
library(doMC)
registerDoMC(cores=4)

data(iris)

X <- as.matrix(iris %>% select(-Species))
y <- as.factor(iris$Species)

clf1 <- glmnet(X, y,
               family = "multinomial")
plot(clf1)

cv.clf1 <- cv.glmnet(X,y,
                     family = "multinomial",
                     parallel = T)
plot(cv.clf1)


clf2 <- train(Species~.,
              data = iris,
              trControl = trainControl("cv", 7),
              method = "glmnet",
              tuneLength = 5)

predict(clf2, iris, type="prob")
