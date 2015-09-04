# from http://mathewanalytics.com/2015/09/02/logistic-regression-in-r/

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

get.auc <- function(model) {

        prob <- predict(model, newdata=testing, type="response")
        pred <- prediction(prob, testing$Class)
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

four <- glm(Class ~ . + (.) * (.),
            data=training,
            family="binomial")
summary(four)
get.auc(four)

