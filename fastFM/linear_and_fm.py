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

def one_fold(fold, clf, X, y, verbose=True):
    
    if verbose:
        print "...",
    
    train, test = fold
    X_train, X_test, y_train, y_test = X[train], X[test], y[train], y[test]
    
    clf.fit(X_train, y_train)
    
    y_prob = clf.predict_proba(X_test)
    score = roc_auc_score(y_test, y_prob)
    
    if verbose: 
        print " fold score = %.4f" % (score)
        
    return score
    
def mcmc_one_fold(fold, clf, X, y, verbose = True):
    
    if verbose:
        print "...",
    
    train, test = fold
    X_train, X_test, y_train, y_test = X[train], X[test], y[train], y[test]
    
    y_prob = clf.fit_predict_proba(X_train, y_train, X_test)
    
    score = roc_auc_score(y_test, y_prob)
    
    if verbose: 
        print " fold score = %.4f" % (score)
        
    return score

##

model = LogisticRegression(penalty='l2', dual=True, tol=0.0001, 
                         C=1, fit_intercept=True, intercept_scaling=1.0, 
                         class_weight=None, random_state=None)
                         
aucs = cross_validation.cross_val_score(model, X, y, cv=k, scoring='roc_auc')
print "Liner model: %d Fold CV Score: %.4f +/- %.4f " % (k, np.mean(aucs), np.std(aucs))

_ = """
## 0.9555
"""

from fastFM import als

fm = als.FMClassification(n_iter=1000, 
                          init_stdev=0.01, 
                          l2_reg=3,
                          rank=8,
                          random_state = 1234)
y2 = np.where(y==1, 1, -1)
aucs = [one_fold(fold, fm, X, y2) for fold in KFold(y.shape[0], n_folds=k)]

print "FM model: %d Fold CV Score: %.4f +/- %.4f " % (k, np.mean(aucs), np.std(aucs))

_ = """
fm = als.FMClassification(n_iter=1000, 
                          init_stdev=0.01, 
                          l2_reg=3,
                          rank=8,
                          random_state = 1234)
#... fold score = 0.9524
#... fold score = 0.9539
#... fold score = 0.9461
#... fold score = 0.9542
#... fold score = 0.9495
#FM model: 5 Fold CV Score: 0.9512 +/- 0.0031
                          
fm = als.FMClassification(n_iter=1000, 
                          init_stdev=0.1, 
                          l2_reg=3,
                          rank=8,
                          random_state = 1234)

"""

from fastFM import mcmc

fm = mcmc.FMClassification(n_iter=500, 
                          init_stdev=0.01,
                          rank=4,
                          random_state = 1234)
y2 = np.where(y==1, 1, -1)
aucs = [mcmc_one_fold(fold, fm, X, y2) for fold in KFold(y.shape[0], n_folds=k)]

print "MCMC FM model: %d Fold CV Score: %.4f +/- %.4f " % (k, np.mean(aucs), np.std(aucs))


_ = """
init_stdev=0.001
...  fold score = 0.9193
...  fold score = 0.9200
...  fold score = 0.9135
...  fold score = 0.9214
...  fold score = 0.9152
MCMC FM model: 5 Fold CV Score: 0.9179 +/- 0.0030

init_stdev=0.1
-> bof

"""

_ = """ 

print "Retrain on all training data, predicting test labels...\n"
model.fit(X,y)
result = model.predict_proba(X_test)[:,1]
output = pd.DataFrame( data={"id":test["id"], "sentiment":result} )

# Use pandas to write the comma-separated output file
output.to_csv('Bag_of_Words_model.csv', index=False, quoting=3)
print "Wrote results to Bag_of_Words_model.csv"

"""