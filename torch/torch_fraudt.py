#%%
import numpy as np
import pandas as pd

import torch
from torch import nn, manual_seed
import torch.nn.functional as F
from torch.optim import Adam, Adagrad, RMSprop, SGD

from skorch import NeuralNetClassifier

import random
from sklearn.model_selection import StratifiedKFold
from evolutionary_search import EvolutionaryAlgorithmSearchCV
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.preprocessing import StandardScaler
#%%
only_test = False

manual_seed(0)

data_file = "~/.kaggle/creditcard.csv"

raw = pd.read_csv(data_file)
if only_test: raw = raw.head(60000)
raw.describe().T

X = np.array(raw[["Amount", "Time"] + ["V%d" % i for i in range(1, 29)]]).astype(np.float32)
y = np.array(raw.Class.astype(np.int64))

scaler = StandardScaler()

#X = scaler.fit_transform(X).astype(np.float32)


print("loaded %s and got %s from %s" % (data_file, str((X.shape, y.shape)), raw.shape))
raw = None


#%%
y_mean = y.mean()

weights = np.array([1, y_mean], dtype=np.float32)

#%%
class MyModule(nn.Module):
    def __init__(self, num_units=10, nonlin=F.relu, input_size=X.shape[1], dropout=0.4):
        super(MyModule, self).__init__()

        self.dense0 = nn.Linear(input_size, num_units)
        self.nonlin = nonlin
        self.dropout1 = nn.Dropout(dropout)
        self.dense1 = nn.Linear(num_units, 10)
        self.output = nn.Linear(10, 2)

    def forward(self, X, **kwargs):
        X = F.normalize(X)
        X = self.nonlin(self.dense0(X))
        X = self.dropout1(X)
        X = F.relu(self.dense1(X))
        X = F.softmax(self.output(X), dim=-1)
        return X


net = NeuralNetClassifier(
    MyModule,
    verbose=0,
#    criterion=nn.NLLLoss, # supposed to work with F.log_softmax but does not...
    criterion__weight=torch.from_numpy(weights),
    max_epochs=10,
    lr=0.1,
    # Shuffle training data on each epoch
    iterator_train__shuffle=True,
    device='cuda',
    optimizer=Adagrad, # to test with another optimizer!
    train_split=None,
)
#%%
params = {
    'lr': [0.3, 0.1, 0.03, 0.01, 0.003, 0.001],
    'max_epochs': [5, 10, 20],
    'module__num_units': [16, 32, 64, 128, 256, 512],
    'module__dropout': [0.1, 0.2, 0.3, 0.4, 0.5],
    'batch_size': [1024, 2048, 4096]
}
#%%
random.seed(2)

cv = EvolutionaryAlgorithmSearchCV(estimator            = net,
                                   params               = params,
                                   scoring              = 'average_precision',
                                   cv                   = StratifiedKFold(n_splits=3),
                                   verbose              = 1,
                                   population_size      = 10,
                                   gene_mutation_prob   = 0.25,
                                   gene_crossover_prob  = 0.5,
                                   tournament_size      = 4,
                                   generations_number   = 4,
                                   n_jobs               = 1,
                                   refit                = False)

cv.fit(X, y)
#%%
