import os
import sys

sys.path.append("../starter")

from KaggleWord2VecUtility import KaggleWord2VecUtility
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn import cross_validation
from sklearn.cross_validation import KFold
from sklearn.metrics import accuracy_score, roc_auc_score

import pandas as pd
import numpy as np

train = pd.read_csv(os.path.join(os.path.dirname(__file__), '../data', 'labeledTrainData.tsv'), header=0, \
                delimiter="\t", quoting=3)
test = pd.read_csv(os.path.join(os.path.dirname(__file__), '../data', 'testData.tsv'), header=0, delimiter="\t", \
               quoting=3 )
y = train["sentiment"]  
print "Cleaning and parsing movie reviews...\n"      
traindata = []
for i in xrange( 0, len(train["review"])):
    traindata.append(" ".join(KaggleWord2VecUtility.review_to_wordlist(train["review"][i], False)))
testdata = []
for i in xrange(0,len(test["review"])):
    testdata.append(" ".join(KaggleWord2VecUtility.review_to_wordlist(test["review"][i], False)))

print 'vectorizing... ', 
tfv = TfidfVectorizer(min_df=3,  
                      max_features=10000, 
                      strip_accents='unicode', 
                      analyzer='word', token_pattern=r'\w{1,}',
                      ngram_range=(1, 2), 
                      use_idf=1, smooth_idf=1, sublinear_tf=1,
                      stop_words = 'english')
X_all = traindata + testdata
lentrain = len(traindata)

print "fitting pipeline... ",
tfv.fit(X_all)
X_all = tfv.transform(X_all)

X = X_all[:lentrain]
X_test = X_all[lentrain:]

k = 5

print "fitting model..."

model = LogisticRegression(penalty='l2', dual=True, tol=0.0001, 
                         C=1, fit_intercept=True, intercept_scaling=1.0, 
                         class_weight=None, random_state=None)
                         
aucs = cross_validation.cross_val_score(model, X, y, cv=k, scoring='roc_auc')
print "Liner model: %d Fold CV Score: %.4f +/- %.4f " % (k, np.mean(aucs), np.std(aucs))

## 
import sys
sys.path.append("/home2/yannick2/github/xgboost/wrapper")

import xgboost as xgb

dtrain = xgb.DMatrix(X, label=y)

watchlist  = [(dtrain,'train')]
num_round = 1600

param = {'objective': 'binary:logistic', 'nthread': 4, 'silent': 1, 
         'eval_metric': 'auc',
         'max_depth': 3,
         'subsample': .8,
         'colsample_bytree': 0.7,
         'eta': 0.1
}
result = xgb.cv(param, dtrain, num_round, nfold=k,
                metrics={'auc'}, seed = 1234)

"""

rf / et -> 0.935

rl = []
rl.append((param,result[-1]))

num_round = 1600

param = {'objective': 'binary:logistic', 
         'silent': 1, 
         'eval_metric': 'auc',
         'max_depth': 3,
         'subsample': .8,
         'colsample_bytree': 0.7,
         'eta': 0.1
}
result = xgb.cv(param, dtrain, num_round, nfold=k, metrics={'auc'}, seed = 1234)
rl.append((param,result[-1]))

#max_depth 3 / subsample 0.8
# eta 0.2 -> .943
# eta 0.1 -> .944
# eta 0.06 -> 0.942
#max_depth 5
# eta 0.1 -> 0.942
# max_depth 5 / subsample 0.5 (because overfit!!!)
# eta 0.2 ->  0.935
# eta 0.1 ->
#max_depth 3 / subsample 0.5
# eta 0.1 -> 0.943
# max_depth 3 / subsample 1.0
# eta 0.1 -> 0.944


num_round = 40

param = {'booster': 'gblinear',
         'objective': 'binary:logistic', 
         'nthread': 4, 
         'silent': True, 
         'eval_metric': 'auc',
         'lambda': 0.6,
         'lambda_bias': 0.6
}

result = xgb.cv(param, dtrain, num_round, nfold=k, metrics={'auc'}, seed = 1234)
rl.append((param,result[-1]))

# lambda et lambda_bias at 0.6
# [39]    cv-test-auc:0.956492+0.001769   cv-train-auc:0.985592+0.00012
1.0 ~ 0.9556
0.3 ~ 0.9561
"""

""" 

print "Retrain on all training data, predicting test labels...\n"
model.fit(X,y)
result = model.predict_proba(X_test)[:,1]
output = pd.DataFrame( data={"id":test["id"], "sentiment":result} )

# Use pandas to write the comma-separated output file
output.to_csv('Bag_of_Words_model.csv', index=False, quoting=3)
print "Wrote results to Bag_of_Words_model.csv"

"""