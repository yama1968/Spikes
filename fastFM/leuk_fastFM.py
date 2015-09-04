# -*- coding: utf-8 -*-
"""
Created on Fri Sep  4 21:20:11 2015

@author: yannick
"""

from sklearn.datasets import fetch_mldata
from sklearn.metrics import confusion_matrix, accuracy_score, roc_auc_score
from sklearn.cross_validation import train_test_split

from scipy.sparse import csc_matrix
import numpy as np
import tempfile

test_data_home = "/tmp"

leuk = fetch_mldata('leukemia', transpose_data=True,
                    data_home=test_data_home)

X = csc_matrix(leuk.data)
y = leuk.target

X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                    test_size = 0.3,
                                                    random_state=1234)


from sklearn.linear_model import LogisticRegression

clf = LogisticRegression()
clf.fit(X_train, y_train)
y_prob = clf.predict_proba(X_test)[:,1]
y_pred = np.where(y_prob > 0.5, 1, -1)

print confusion_matrix(y_test, y_pred)
print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_prob)


from sklearn.ensemble import RandomForestClassifier

clf = RandomForestClassifier()
clf.fit(X_train, y_train)
y_prob = clf.predict_proba(X_test)[:,1]
y_pred = np.where(y_prob > 0.5, 1, -1)

print confusion_matrix(y_test, y_pred)
print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_prob)


from fastFM import sgd, als

fm = als.FMClassification(n_iter=1000, init_stdev=0.01, 
                          l2_reg=0.01,
                          rank=7,
                          random_state = 1234)
fm.fit(X_train, y_train)

y_pred_proba = fm.predict_proba(X_test)
y_pred = np.where(y_pred_proba > 0.5, 1, -1)

print confusion_matrix(y_test, y_pred)
print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_pred_proba)
