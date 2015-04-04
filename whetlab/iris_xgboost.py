# -*- coding: utf-8 -*-


import whetlab
from math import log, exp
import sys
import re
from sklearn.datasets import load_iris
import numpy as np
from numpy.random import permutation
from sklearn.metrics import confusion_matrix

sys.path.append("/home2/yannick2/github/xgboost/wrapper")
import xgboost as xgb

data = load_iris()

X = data.data
y = data.target

perm = permutation(np.arange(X.shape[0]))
X = X[perm]
y = y[perm]

Xt = X[:40]
yt = y[:40]
X = X[40:]
y = y[40:]

dtrain = xgb.DMatrix(X, label=y)
dtest = xgb.DMatrix(Xt, label=yt)
watchlist = [(dtrain, 'train'), (dtest, 'test')]

param={'max_depth': 10, 'eta': 0.031, 'objective': 'multi:softmax',
       'num_class': 3,'eval_metric': 'merror'}

sys.stderr.write(str(param) + "\n")    

bst = xgb.train(param, dtrain, 50, watchlist )

sys.stderr.write(str(confusion_matrix(yt, bst.predict(dtest))) + "\n")
    
 