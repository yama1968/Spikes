# from http://mathewanalytics.com/2015/09/02/logistic-regression-in-r/

library(doMC)
registerDoMC(cores = 4)

library(caret)
data(GermanCredit)

set.seed(1234)

Train <- createDataPartition(GermanCredit$Class, p=0.6, list=FALSE)
training <- GermanCredit[Train,]
testing <- GermanCredit[-Train,]

mod_fit_one <- glm(Class ~ Age + ForeignWorker + Property.RealEstate +
                     Housing.Own + CreditHistory.Critical,
                   data = training,
                   family = "binomial")

summary(mod_fit_one)
exp(coef(mod_fit_one))

library(ROCR)

get.auc <- function(model, type="response") {
  
  prob <- predict(model, newdata=testing, type=type)
  pred <- prediction(prob, testing$Class)
  perf <- performance(pred, measure="tpr", x.measure="fpr")
  plot(perf)
  auc <- performance(pred, measure="auc")
  auc <- auc@y.values[[1]]
  auc
}

get.auc2 <- function(model, type="prob") {
  
  prob <- predict(model, newdata=testing, type=type)
  pred <- prediction(prob$Good, testing$Class)
  perf <- performance(pred, measure="tpr", x.measure="fpr")
  plot(perf)
  auc <- performance(pred, measure="auc")
  auc <- auc@y.values[[1]]
  auc
}

get.auc(mod_fit_one)

mod_fit_two <- glm(Class ~ ., data=training, family="binomial")
get.auc(mod_fit_two)

three <- glm(Class ~ Amount + InstallmentRatePercentage + Telephone + ForeignWorker +
               CheckingAccountStatus.lt.0 + CheckingAccountStatus.0.to.200 +
               CheckingAccountStatus.gt.200 +
               CreditHistory.NoCredit.AllPaid + CreditHistory.ThisBank.AllPaid +
               CreditHistory.PaidDuly + SavingsAccountBonds.lt.100 +
               OtherInstallmentPlans.Bank,
             data=training,
             family="binomial")
summary(three)
get.auc(three)

# four <- glm(Class ~ . + (.) * (.),
#             data=training,
#             family="binomial")
# summary(four)
# get.auc(four)


g1 <- train(Class ~ . - Purpose.Vacation - Personal.Female.Single,
            data          = training,
            trControl     = trainControl("cv", 7, classProbs=TRUE, summaryFunction = twoClassSummary),
            preProc       = c("BoxCox", "center", "scale"),
            method        = "glmnet",
            metric        = "ROC",
            tuneLength    = 20)

get.auc2(g1, type="prob")

g2 <- train(Class ~ . - Purpose.Vacation - Personal.Female.Single,
            data          = training,
            trControl     = trainControl("adaptive_cv", 7, classProbs=TRUE, summaryFunction = twoClassSummary,
                                         adaptive = list(min = 5,
                                                         alpha = 0.05,
                                                         method = "gls",
                                                         complete = TRUE)),
            preProc       = c("BoxCox", "center", "scale"),
            method        = "glmnet",
            metric        = "ROC",
            tuneLength    = 20)
get.auc2(g2, type="prob")

cart1 <- train(Class ~ . - Purpose.Vacation - Personal.Female.Single,
               data          = training,
               trControl     = trainControl("adaptive_cv", 7, classProbs=TRUE, summaryFunction = twoClassSummary,
                                            adaptive = list(min = 5,
                                                            alpha = 0.05,
                                                            method = "gls",
                                                            complete = TRUE)),
               method        = "rpart",
               metric        = "ROC",
               tuneLength    = 20)
get.auc2(cart1, type="prob")


