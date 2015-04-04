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

prop = 60

Xt = X[:prop]
yt = y[:prop]
X = X[prop:]
y = y[prop:]

dtrain = xgb.DMatrix(X, label=y)
dtest = xgb.DMatrix(Xt, label=yt)
watchlist = [(dtrain, 'train'), (dtest, 'test')]

param={'max_depth': 3, 'eta': 0.006, 'objective': 'multi:softmax',
       'num_class': 3,'eval_metric': 'merror', 'subsample': 0.5}

sys.stderr.write(str(param) + "\n")    

bst = xgb.train(param, dtrain, 10, watchlist )

sys.stderr.write(str(confusion_matrix(yt, bst.predict(dtest))) + "\n")
sys.stderr.write(str(confusion_matrix(y, bst.predict(dtrain))) + "\n")

 