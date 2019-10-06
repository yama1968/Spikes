#%%
# from __future__ import absolute_import, division, print_function, unicode_literals

import os
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"   # see issue #152
os.environ["CUDA_VISIBLE_DEVICES"] = ""

import tensorflow as tf
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier

import numpy as np
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

from imblearn.over_sampling import SMOTE, RandomOverSampler
from imblearn.keras import BalancedBatchGenerator


only_test = False

data_file = "~/.kaggle/creditcard.csv"

raw = pd.read_csv(data_file)
if only_test: raw = raw.head(60000)
raw.describe().T

X = np.array(raw[["Amount", "Time"] + ["V%d" % i for i in range(1, 29)]]).astype(np.float32)
y = np.array(raw.Class.astype(np.int64))

scaler = StandardScaler()

X = scaler.fit_transform(X).astype(np.float32)


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
                n_layers=3,
                batch_size=2048,
                n_input=30,
                n_class=2):
  
  layers = ([tf.keras.layers.Dense(n_first, input_shape=(n_input,), activation='relu')] +
            ([tf.keras.layers.Dropout(dropout_first)] if dropout_first > 0 else []) +
            flatten([[tf.keras.layers.Dense(n_second, activation='relu'),
                     tf.keras.layers.Dropout(dropout_second)] for i in range(n_layers-1)]) +
            [tf.keras.layers.Dense(1, activation='sigmoid')])
  for layer in layers: print(layer)
  model = tf.keras.models.Sequential(layers)
  model.compile(optimizer='adam',
                loss='binary_crossentropy',
                metrics=['accuracy', 'AUC', aucpr],
                batch_size=batch_size)
  return model
#%%
model = KerasClassifier(build_fn=build_model,
                        n_input=x_train.shape[-1], n_class=2,
                        )

history = model.fit(x_train, y_train, epochs=10,
                    validation_split=0,
                    verbose=0)

y_hat = model.predict_proba(x_test)[:,1]
print("test score = %.3f" % average_precision_score(y_test, y_hat))
#%%
