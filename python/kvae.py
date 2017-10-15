'''
Library for variational autoencoder with Keras.

Reference: 
> "Auto-Encoding Variational Bayes" https://arxiv.org/abs/1312.6114
> https://github.com/fchollet/keras/blob/master/examples/variational_autoencoder.py
'''

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
from functools import partial

from keras.layers import Input, Dense, Lambda, Layer, Concatenate
from keras.models import Model
from keras import backend as K
from keras import metrics
from keras.datasets import mnist



# Custom loss layer
class CustomVariationalLayer(Layer):
    def __init__(self, **kwargs):
        self.is_placeholder = True
        super(CustomVariationalLayer, self).__init__(**kwargs)

    def vae_loss(self, x, x_decoded_mean, z_mean, z_log_var):
        original_dim = K.int_shape(x)[1]

        xent_loss = (original_dim *
                     metrics.binary_crossentropy(x, x_decoded_mean))
        kl_loss = - 0.5 * K.sum(1 + z_log_var
                                - K.square(z_mean)
                                - K.exp(z_log_var),
                                axis=-1)
        return K.mean(xent_loss + kl_loss)

    def call(self, inputs):
        x = inputs[0]
        x_decoded_mean = inputs[1]
        z_mean = inputs[2]
        z_log_var = inputs[3]
        loss = self.vae_loss(x, x_decoded_mean, z_mean, z_log_var)
        self.add_loss(loss, inputs=inputs)
        # We won't actually use the output.
        return x


def sampling(latent_dim, epsilon_std, args):
    z_mean, z_log_var = args
    epsilon = K.random_normal(shape=(K.shape(z_mean)[0], latent_dim),
                              mean=0.,
                              stddev=epsilon_std)
    return z_mean + K.exp(z_log_var / 2) * epsilon


def buildVAE(input_dim,
             hidden_dims=[64],
             latent_dim=2,
             epsilon_std=0.25):

    x = Input(shape=(input_dim,))

    h = x
    for d in hidden_dims:
        h = Dense(d, activation="relu")(h)

    z_mean = Dense(latent_dim)(h)
    z_log_var = Dense(latent_dim)(h)

    z = Lambda(partial(sampling, latent_dim, epsilon_std),
               output_shape=(latent_dim,))\
              ([z_mean, z_log_var])

    decoders_h = list()
    h_decoded = z
    for d in reversed(hidden_dims):
        decoder_h = Dense(d, activation='relu')
        h_decoded = decoder_h(h_decoded)
        decoders_h.append(decoder_h)

    decoder_mean = Dense(input_dim, activation='sigmoid')
    x_decoded_mean = decoder_mean(h_decoded)

    y = CustomVariationalLayer()([x, x_decoded_mean, z_mean, z_log_var])
    vae = Model(x, y)
    vae.compile(optimizer='rmsprop', loss=None)
    encoder = Model(x, z_mean)

    sigmaEncoder = Model(x, z_log_var)

    decoder_input = Input(shape=(latent_dim,))
    _h_decoded = decoder_input
    for decoder_h in decoders_h:
        _h_decoded = decoder_h(_h_decoded)
    _x_decoded_mean = decoder_mean(_h_decoded)

    decoder = Model(decoder_input, _x_decoded_mean)

    return vae, encoder, decoder, sigmaEncoder


class VariationalAutoencoder(object):

    def _buildVAE(self):
        None

    def __init__(self,
                 input_dim,
                 hidden_dims=[64],
                 latent_dim=2,
                 epsilon_std=0.25):
        self.input_dim = input_dim
        self.hidden_dims = hidden_dims
        self.latent_dim = latent_dim
        self.epsilon_std = epsilon_std

        self.vae, \
        self.encoder, \
        self.decoder, \
        self.zlogvarEncoder = \
            buildVAE(self.input_dim,
                     self.hidden_dims,
                     self.latent_dim,
                     self.epsilon_std)

    def fit(self, *args, **kwargs):
        return self.vae.fit(*args, **kwargs)

    def predict(self, *args, **kwargs):
        return self.vae.predict(*args, **kwargs)

    def summary(self):
        return self.vae.summary()

    def encode(self, x, batch_size=128):
        return self.encoder.predict(x, batch_size)

    def zlogvarEncode(self, x, batch_size=128):
        return self.zlogvarEncoder.predict(x, batch_size)
    
    def sigmaEncode(self, x, batch_size=128):
        return np.exp(self.zlogvarEncode(x, batch_size)/2)
  
    def generate(self, z, batch_size=128):
        return self.decoder.predict(z, batch_size)
    
    def samplingEncoder(self, x, batch_size=128):
        None
