
library(rpart)
library(rpart.plot)

# load data
data(iris)

# fit model
fit <- rpart(Species~., data=iris)

# summarize the fit
summary(fit)

# make predictions
predictions <- predict(fit, iris[,1:4], type="class")

# summarize accuracy
table(predictions, iris$Species)

