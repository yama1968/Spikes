from __future__ import absolute_import, division, print_function, unicode_literals

import tensorflow as tf

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

##

(x_train, x_test, y_train, y_test) = train_test_split(X, y, 
                                                      test_size=.33, 
                                                      random_state=42,
                                                      stratify=y)


training_generator = BalancedBatchGenerator(x_train, y_train,
                                            sampler=RandomOverSampler(sampling_strategy=1.),
                                            batch_size=2048,
                                            random_state=42)


model = tf.keras.models.Sequential([
  tf.keras.layers.Dense(256, input_shape=(x_train.shape[-1],), activation='relu'),
  tf.keras.layers.Dropout(0.3),
  tf.keras.layers.Dense(256, activation='relu'),
  tf.keras.layers.Dropout(0.3),
  tf.keras.layers.Dense(1, activation='sigmoid')
])


from sklearn.metrics import roc_auc_score, average_precision_score

def aucpr(y_true, y_pred):
    return tf.py_function(average_precision_score, (y_true, y_pred), tf.double)

class_weight = {0: 1., 1: 1/y_train.mean()} # shall we use them?


model.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy', aucpr])

model.fit(x_train, y_train, epochs=7)
# model.fit_generator(training_generator, epochs=7)
model.evaluate(x_test, y_test, verbose=4)


y_hat = model.predict_proba(x_test)
print("test score = %.3f" % average_precision_score(y_test, y_hat))