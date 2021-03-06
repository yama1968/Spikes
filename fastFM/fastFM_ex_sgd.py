# -*- coding: utf-8 -*-
"""
Created on Fri Sep  4 21:20:11 2015

@author: yannick
"""
from fastFM.datasets import make_user_item_regression
from sklearn.cross_validation import train_test_split

# This sets up a small test dataset.
X, y, _ = make_user_item_regression(label_stdev=.4)
X_train, X_test, y_train, y_test = train_test_split(X, y)

import numpy as np

# Convert dataset to binary classification task.
y_labels = np.ones_like(y)
y_labels[y < np.mean(y)] = -1
X_train, X_test, y_train, y_test = train_test_split(X, y_labels)

from fastFM import sgd
fm = sgd.FMClassification(n_iter=100, init_stdev=0.1, l2_reg_w=0,
                          l2_reg_V=0, rank=2, step_size=0.1)
fm.fit(X_train, y_train)

y_pred_proba = fm.predict_proba(X_test)
y_pred = np.where(y_pred_proba > 0.5, 1, -1)

from sklearn.metrics import accuracy_score, roc_auc_score
print 'acc:', accuracy_score(y_test, y_pred)
print 'auc:', roc_auc_score(y_test, y_pred_proba)
