
library(RCurl)
library(xrf)

# grabbing data from uci
census_income_text <- getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data')
census_income <- read.csv(textConnection(census_income_text), header=F, stringsAsFactors = F)
colnames(census_income) <- c('age', 'workclass', 'fnlwgt', 'education', 'education_num', 'marital_status',
                             'occupation', 'relationship', 'race', 'sex', 'capital_gain', 'capital_loss',
                             'hours_per_week', 'native_country', 'above_50k')

m_xrf <- xrf(above_50k ~ ., census_income, family = 'binomial',
             xgb_control = list(nrounds = 100, max_depth = 3))

