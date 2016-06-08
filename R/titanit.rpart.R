
library(rpart)
library(rpart.plot)
data(ptitanic)

lapply(ptitanic,class)

attr(ptitanic$age,"class") <- NULL
class(ptitanic$age)

ptitanicTree <- rpart(survived~., data=ptitanic)

ptitanicTree2 <- rpart(survived~., 
                      data=ptitanic, 
                      control=rpart.control(minsplit=5,cp=0))

prp(ptitanicTree)
prp(ptitanicTree2)

ptitanicSimple <- prune(ptitanicTree2, cp=0.0047)

prp(ptitanicSimple)

# make predictions
predictions <- predict(ptitanicSimple, ptitanic, type="class")
probs <- predict(ptitanicSimple, ptitanic, type = "prob")


# summarize accuracy
table(predictions, ptitanic$survived)
