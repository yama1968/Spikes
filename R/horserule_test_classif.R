
library(RCurl)
library(dplyr)
library(PRROC)
library(horserule)

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
    above_50k = as.logical(as.character(above_50k) == ' >50K')
  ) %>%
  na.omit

aucroc <- function(prediction, actual) {
  stopifnot(length(unique(actual)) == 2)
  stopifnot(length(prediction) == length(actual))
  mann_whit <- wilcox.test(prediction ~ actual)$statistic
  unname(1 - mann_whit/(sum(actual) * as.double(sum(!actual))))
}

aucpr <- function(prediction, actual) {
  pr.curve(prediction[actual == 1], prediction[actual == 0], curve = FALSE)$auc.integral
}


set.seed(55455)
train_ix <- sample(nrow(census_income), floor(nrow(census_income) * .7))
X_train <- census_income[train_ix, -15]
y_train <- census_income[train_ix, 15]
X_test <- census_income[-train_ix, -15]
y_test <- census_income[-train_ix, 15]

system.time(
  hrres <- HorseRuleFit(X = X_train, y = y_train,
                        thin = 2, niter = 3000, burnin = 1000,
                        L = 10, S = 6, ensemble = "both", mix = 0.3, ntree = 400,
                        intercept = T, linterms = c(1, 5, 11, 12, 13),
                        alpha = 1, beta = 2, linp = 2, restricted = 0)
)

# L = 10 => 0.807 aucpr
# L = 30 => toujours 10 règles et 0.812 aucpr
# L = 10 & niter = 3000 thin = 2 => 0.816

y_hat <- predict(hrres, X_test, burnin = 100)
length(y_hat)
aucroc(y_hat, y_test)
aucpr(y_hat, y_test)

importance_hs(hrres, k = 30) %>% View

Variable_importance(hrres)
