# -*- coding: utf-8 -*-
"""
Created on Fri Sep  4 21:20:11 2015

@author: yannick
"""

from sklearn.datasets import load_iris
from sklearn.metrics import confusion_matrix, accuracy_score, roc_auc_score
from sklearn.cross_validation import train_test_split

from scipy.sparse import csc_matrix
import numpy as np

iris = load_iris()
X = csc_matrix(iris.data)
y = iris.target
y = np.where(y >= 2, 1, -1)

X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1234)

from fastFM import sgd, als

fm = als.FMClassification(n_iter=100, init_stdev=0.01, 
                          l2_reg=0.1,
                          rank=5,
                          random_state = 1234)
fm.fit(X_train, y_train)

y_pred_proba = fm.predict_proba(X_test)
y_pred = np.where(y_pred_proba > 0.5, 1, -1)

print confusion_matrix(y_test, y_pred)
print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_pred_proba)
