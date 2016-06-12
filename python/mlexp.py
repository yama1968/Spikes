
from sys import stderr
from random import seed
import numpy as np
from math import log

from hsdata import *

from sklearn.pipeline import FeatureUnion
from sklearn.cross_validation import train_test_split

from sklearn.metrics import roc_auc_score
import xgboost as xgb


class MLExperiment(object):

    def __init__(self, transformer):
        self.best_learner = None
        self.transformer = transformer
        self.best_learner = None
        self.best_point = None
        self.best_score = 1e10

    def train_test(params):
        None

    def predict(self, X):

        transformed_X = self.transformer(X)
        return self.best_learner.predict(transformed_X)


class SplitExperiment(MLExperiment):

    def prepare(self, X, target):

        y = X[target]
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=self.test_prop, random_state=1234)

        drp = FixDrop([target])

        X_train = self.transformer.fit_transform(X_train)
        self.X_train = drp.fit_transform(X_train)
        self.y_train = y_train

        X_test = self.transformer.transform(X_test)
        self.X_test = drp.transform(X_test)
        self.y_test = y_test
