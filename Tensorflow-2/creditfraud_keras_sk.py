#%%
# from __future__ import absolute_import, division, print_function, unicode_literals

"""
import os
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"   # see issue #152
os.environ["CUDA_VISIBLE_DEVICES"] = ""
"""

import tensorflow as tf
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier

import numpy as np
import pandas as pd
import random

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import StratifiedKFold

from evolutionary_search import EvolutionaryAlgorithmSearchCV
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV


only_test = False

data_file = "~/.kaggle/creditcard.csv"

raw = pd.read_csv(data_file)
if only_test: raw = raw.head(60000)
raw.describe().T

X = np.array(raw[["Amount", "Time"] + ["V%d" % i for i in range(1, 29)]])
y = np.array(raw.Class)

scaler = StandardScaler()

X = scaler.fit_transform(X)

print("loaded %s and got %s from %s" % (data_file, str((X.shape, y.shape)), raw.shape))
raw = None

(x_train, x_test, y_train, y_test) = train_test_split(X, y, 
                                                      test_size=.33, 
                                                      random_state=42,
                                                      stratify=y)


flatten = lambda l: [item for sublist in l for item in sublist]

from sklearn.metrics import roc_auc_score, average_precision_score

def aucpr(y_true, y_pred):
    return tf.py_function(average_precision_score, (y_true, y_pred), tf.double)
#%%
def build_model(n_first=512, n_second=256, 
                dropout_first=0., dropout_second=0.4,
                add_layers=2,
                learning_rate=0.001, epsilon=1e-8):
  
  layers = ([tf.keras.layers.Dense(n_first, activation='relu')] +
            ([tf.keras.layers.Dropout(dropout_first)] if dropout_first > 0 else []) +
            flatten([[tf.keras.layers.Dense(n_second / 2**i, activation='relu'),
                     tf.keras.layers.Dropout(dropout_second)] for i in range(add_layers)]) +
            [tf.keras.layers.Dense(1, activation='sigmoid')])
  
  model = tf.keras.models.Sequential(layers)
  model.compile(optimizer='adam',
                learning_rate=learning_rate,
                epsilon=epsilon,
                loss='binary_crossentropy',
                metrics=['AUC'])
  return model
#%%
model = KerasClassifier(build_fn=build_model,
                        add_layers=2,
                        epochs=20,
                        validation_split=0,
                        batch_size=2048
                        )

history = model.fit(x_train, y_train)

y_hat = model.predict_proba(x_test)[:,1]
print("test score = %.3f" % average_precision_score(y_test, y_hat))
#%%
params = {
    'epochs': [5, 10, 20, 30],
    'n_first': 64 * 2**np.arange(6),
    'n_second': 64 * 2**np.arange(6),
    'dropout_first': 0.1 * np.arange(8),
    'dropout_second': 0.1 * np.arange(8),
    'add_layers': range(4),
    'batch_size': [1024, 2048, 4096, 8192],
    'learning_rate': 1E-6 * 10 ** (np.arange(8) / 2.),
    'epsilon': 10. ** -np.arange(7, 10)
}
#%%
random.seed(2)

clf = KerasClassifier(build_fn=build_model, verbose=0, validation_split=0.)

cv = EvolutionaryAlgorithmSearchCV(estimator            = clf,
                                   params               = params,
                                   scoring              = 'average_precision',
                                   cv                   = StratifiedKFold(n_splits=5),
                                   verbose              = 1,
                                   population_size      = 40,
                                   gene_mutation_prob   = 0.25,
                                   gene_crossover_prob  = 0.5,
                                   tournament_size      = 4,
                                   generations_number   = 10,
                                   n_jobs               = 1,
                                   refit                = False)

cv.fit(X, y)
#%%