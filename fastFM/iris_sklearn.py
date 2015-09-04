# -*- coding: utf-8 -*-
"""
Éditeur de Spyder

Ce script temporaire est sauvegardé ici :
/home/yannick/.spyder2/.temp.py
"""

from sklearn.linear_model import SGDClassifier, RidgeClassifier, LogisticRegression
from sklearn.datasets import load_iris
from sklearn.metrics import confusion_matrix, accuracy_score, roc_auc_score
from sklearn.cross_validation import train_test_split
import numpy as np

iris = load_iris()
X = iris.data
y = iris.target

clf = LogisticRegression()
clf.fit(X,y)

clf.predict(X)

print confusion_matrix(y, clf.predict(X))

y0 = np.zeros(y.shape)
y0[y == 0] = -1
y0[y == 1] = -1
y0[y == 2] = 1

clf.fit(X,y0)
print confusion_matrix(y0, clf.predict(X))

X_train, X_test, y_train, y_test = train_test_split(X, y0)

clf.fit(X_train, y_train)
y_prob = clf.predict_proba(X_test)[:,1]
y_pred = np.where(y_prob > 0.5, 1, -1)

print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_prob)
