# -*- coding: utf-8 -*-


import whetlab
from math import log, exp
import sys
import re
from sklearn.datasets import load_iris
import numpy as np
from numpy.random import permutation

sys.path.append("/home2/yannick2/github/xgboost/wrapper")
import xgboost as xgb

data = load_iris()

X = data.data
y = data.target

perm = permutation(np.arange(X.shape[0]))
X = X[perm]
y = y[perm]

dtrain = xgb.DMatrix(X, label=y)

param_grid = \
    	{'max_depth' : {'min': 2, 'max': 10, 'type': 'integer'},
      'subsample' : {'min': 0.3, 'max': 1.0, 'type': 'float'},
      'eta' : {'min': log(0.01), 'max': log(1), 'type': 'float'},
      'num_round': {'min': 10, 'max': 150, 'type': 'integer'}}

scientist = whetlab.Experiment(name = "Iris - xgboost-multi - 20150404",
                               description = "",
                               parameters = param_grid,
                               outcome = {"name" : "accuracy"})

n_iter = 20

p = re.compile("[a-z-]*:(0\.[0-9]*)")

for i in range(n_iter):
    job = scientist.suggest()
    param = {'objective': 'multi:softmax', 'num_class': 3,
             'nthreads': 8, 'silent': 1, 'eval_metric': 'merror'}
    param.update(job)
    param['eta'] = exp(param['eta'])
    num_round = param['num_round']    
    del param['num_round']
    
    sys.stderr.write(str(param) + "\n")    
    
    result = xgb.cv(param, dtrain, num_round, nfold=3,
                      metrics={'merror'}, seed=1234)
    acc = 1-float(p.match(result[-1][7:]).group(1))
    
    sys.stderr.write("%s --> %.4f\n" % (str(param), acc))

    scientist.update(job, acc)
    
 