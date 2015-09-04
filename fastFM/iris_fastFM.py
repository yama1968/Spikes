# -*- coding: utf-8 -*-
"""
Éditeur de Spyder

Ce script temporaire est sauvegardé ici :
/home/yannick/.spyder2/.temp.py
"""

from sklearn.datasets import load_iris
from sklearn.metrics import confusion_matrix, accuracy_score, roc_auc_score
from sklearn.cross_validation import train_test_split

from scipy.sparse import csc_matrix
import numpy as np
from fastFM import sgd, als, mcmc

iris = load_iris()
X = csc_matrix(iris.data)
y = iris.target
y0 = np.where(y >= 2, 1, -1)

clf = sgd.FMClassification(n_iter=10, init_stdev=1, l2_reg_w=0.1,
                           l2_reg_V=0.1, rank=10)
clf.fit(X,y0)

print confusion_matrix(y0, clf.predict(X))

clf = mcmc.FMClassification(n_iter=1000, rank=10, init_stdev=0.1)
y_pred = clf.fit_predict(X, y0, X)

print confusion_matrix(y0, y_pred)

X_train, X_test, y_train, y_test = train_test_split(X, y0, random_state=1234)
y_prob = clf.fit_predict_proba(X_train, y_train, X_test)
y_pred = np.where(y_prob > 0.5, 1, -1)
print confusion_matrix(y_test, y_pred)

print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_prob)

