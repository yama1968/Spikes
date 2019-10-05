from __future__ import absolute_import, division, print_function, unicode_literals

# Install TensorFlow
try:
  # %tensorflow_version only exists in Colab.
  %tensorflow_version 2.x
except Exception:
  pass

import tensorflow as tf

from imblearn.over_sampling import SMOTE
from imblearn.keras import BalancedBatchGenerator


mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

training_generator = BalancedBatchGenerator(x_train, y_train,
                                            sampler=SMOTE(sampling_strategy=0.1),
                                            batch_size=1000,
                                            random_state=42)


model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(256, activation='relu'),
  tf.keras.layers.Dropout(0.5),
  tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit_generator(training_generator, epochs=30)

model.evaluate(x_test,  y_test, verbose=4)