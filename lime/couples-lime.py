
# coding: utf-8

# In[1]:

import pandas as pd
import numpy as np
import xgboost as xgb

from sys import argv

from sklearn.pipeline import make_pipeline, Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder, LabelEncoder
from sklearn.pipeline import FeatureUnion
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier
from sklearn.metrics import f1_score, roc_auc_score

from lime.lime_tabular import LimeTabularExplainer


# In[2]:

# Class to help select categorical vs. continuous data as part of the pipeline (see below)
class DataSelector(BaseEstimator, TransformerMixin):
    '''Select columns of numpy arrays based on attribute_indices.'''

    def __init__(self, attribute_indices):
        self.attribute_indices = attribute_indices

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return np.array(X)[:,self.attribute_indices]


# In[3]:

# Load (preprocessed) data
#
# The raw data was downloaded from https://data.stanford.edu/hcmst and preprocessed.
# We combined data sets collected across several years, we transformed select variables
# (e.g., partner_education to be at the same level of granularity as education),
# and added variables like the absolute age difference, education difference, etc.
# Finally, we determined whether couples were still together (i.e., our labels).
#
# We provide the preprocessed data as a csv file in the same repo as this notebook.

df = pd.read_csv('couples.csv')

# Order features (numeric first, categorical second) since it's convenient later
feature_order = ['age',
                 'partner_age',
                 'age_diff_abs',
                 'children',
                 'visits_relatives',
                 'education',
                 'marital_status',
                 'partner_education',
                 'gender',
                 'house',
                 'income',
                 'msa',
                 'rent',
                 'political',
                 'religion',
                 'work',
                 'gender_older',
                 'education_difference',
                 'success']

data = df[feature_order]
data = data[data.house != 'boat, rv, van, etc.'] # only one data point with this value, discard

labels = data.pop('success')



# In[5]:

# Define categorical names and indices
categorical_features = list(data.columns[5:])
categorical_idx = list(range(5, len(data.columns)))
continuous_features = list(data.columns[0:5])
continuous_idx = list(range(0,5))

X = data.values

# Get feature names and their values for categorical data (needed for LIME)
categorical_names = {}
for idx, feature in zip(categorical_idx, categorical_features):
    le = LabelEncoder()
    X[:, idx] = le.fit_transform(X[:, idx])
    categorical_names[idx] = le.classes_

# To suppress a warning later (not strictly necessary)
X = X.astype(float)

# Train test split
train, test, labels_train, labels_test = train_test_split(
    X, labels, train_size=0.70, random_state=42
)


# In[6]:

labels_train.unique(), labels_test.unique()


# In[7]:

# Preprocessing pipeline
#
# LIME needs a function that takes raw inputs and returns a prediction (see below).
# We use sklearn's pipeline to handle preprocessing, it simplifies the interaction with LIME (see below).
# There are several ways to build this pipeline. For demo purposes, we here show the verbose option (and we
# avoid scaling one-hot encoded features).

continuous_pipeline = Pipeline([
    ('selector', DataSelector(continuous_idx)),
    ('scaler', StandardScaler()),
    ])

categorical_pipeline = Pipeline([
    ('selector', DataSelector(categorical_idx)),
    ('encoder', OneHotEncoder(sparse=False)),
    ])

preprocessing_pipeline = FeatureUnion(transformer_list=[
    ("continuous_pipeline", continuous_pipeline),
    ("categorical_pipeline", categorical_pipeline),
    ])

# There are less verbose alternatives, especially if we scale one-hot encoded features,
# an accepted practice in the machine learning community:
#
#     preprocessing_pipeline = Pipeline([
#        ('onehotencoder', OneHotEncoder(categorical_features=categorical_idx, sparse=False)),
#        ('scaler', StandardScaler())
#     ])
#
# Finally, instead of the low-level Pipeline constructor, we can use sklearn's makepipeline:
#
#     preprocessing_pipeline = make_pipeline(
#         OneHotEncoder(categorical_features=categorical_idx, sparse=False),
#         StandardScaler()
#     )


# In[8]:

from hyperopt import fmin, tpe, hp, Trials, STATUS_OK
from functools import partial
from math import log, exp, log10


# In[9]:

if "onehot" in argv:
    train_onehot = preprocessing_pipeline.fit_transform(train)
    test_onehot = preprocessing_pipeline.transform(test)

    def  make_the_pipeline(f):
        return make_pipeline(preprocessing_pipeline, f)

    dtrain = xgb.DMatrix(train_onehot, label=labels_train)

else:
    train_onehot = train
    test_onehot = test
    def make_the_pipeline(f):
        return f
    dtrain = xgb.DMatrix(train, label=labels_train)


# In[10]:

from datetime import datetime

num_round = 900

defaults = {
    'objective': 'binary:logistic',
    'silent': True
}

trials = Trials()
the_best = 0

start = datetime.now()


def hyperopt_train_test(params):

    global the_best

    params["max_depth"] +=1
    params["eta"] = exp(params["eta"])
    params.update(defaults)

    r = xgb.cv(params, dtrain, num_round, nfold=7,
               metrics={'auc'},
               early_stopping_rounds=40)

    weight = float(r.tail(1)["test-auc-mean"])

    if the_best > -weight:
        the_best = -weight
        print(params, " => ", -weight)
        print(r.tail(1))
        print(str(datetime.now() - start))

    return -weight


space4xgb = {
    'max_depth':        hp.choice('max_depth', range(0, 10)),
    'eta':              hp.uniform('eta', log(0.03), log(0.5)),
    'gamma':            hp.uniform('gamma', 0, 30),
    'colsample_bytree': hp.uniform('colsample_bytree', 0.2, 1.0),
    'colsample_bylevel': hp.uniform('colsample_bylevel', 0.2, 1.0),
    'subsample':        hp.uniform('subsample', 0.2, 1.0)
}


def f(params):
    acc = hyperopt_train_test(params)
    return {'loss': acc, 'status': STATUS_OK}


from evolutionary_search import EvolutionaryAlgorithmSearchCV

paramgrid = {'max_depth':   np.arange(0, 10),
             'learning_rate':         np.logspace(log10(0.03), log10(0.5), num=10, base=10),
             'gamma':       np.arange(0, 30),
             'colsample_bytree': np.arange(0.2, 1.05, 0.05),
             'colsample_bylevel': np.arange(0.2, 1.05, 0.05),
             'subsample': np.arange(0.2, 1.05, 0.05)
}

if "deap" in argv:
    best = EvolutionaryAlgorithmSearchCV(estimator=xgb.XGBClassifier(),
                                   params=paramgrid,
                                   scoring="roc_auc",
                                   cv=7,
                                   verbose=1,
                                   population_size=200,
                                   gene_mutation_prob=0.15,
                                   gene_crossover_prob=0.7,
                                   tournament_size=9,
                                   generations_number=40,
                                   n_jobs=8)
    best.fit(train_onehot, labels_train)
else:
    best = fmin(f, space4xgb, algo=partial(tpe.suggest, n_startup_jobs=1), max_evals=1000, trials=trials)


# In[50]:

param = {'max_depth': 7,
         'learning_rate': 0.118,
         'gamma': 4.3,
         'colsample_bytree': 0.92,
         'colsample_bylevel': 0.80,
         'subsample': 0.41,
         'objective': 'binary:logistic',
         'silent': 20,
         'n_estimators': 100} # 0.85 / 0.94

if 'onehot' in argv:
    param = {'max_depth': 6,
             'learning_rate': 0.0525,
             'gamma': 0,
             'colsample_bytree': 0.75,
             'colsample_bylevel': 0.59,
             'subsample': 0.46,
             'objective': 'binary:logistic',
             'silent': 20,
             'n_estimators': 100} #
else:
    param = {'max_depth': 6,
             'learning_rate': 0.133,
             'gamma': 6.6,
             'colsample_bytree': 0.94,
             'colsample_bylevel': 0.91,
             'subsample': 0.63,
             'objective': 'binary:logistic',
             'silent': 20,
             'n_estimators': 800} # 0.863 / 0.946


if False:
    rf = xgb.XGBClassifier(class_weight='balanced')
    rf = rf.set_params(**param)

    pipeline = make_the_pipeline(rf)
    pipeline.fit(train, labels_train,
                 eval_set=[(test, labels_test), (train, labels_train)],
                 eval_metric="auc",
                 verbose=True)


    # In[52]:

    # Evalute random forest classifier on training data (it overfits, small sample size)
    y_predict = pipeline.predict(train)
    f1 = f1_score(labels_train, y_predict)
    print('F1 on train:', f1)

    # Evalute random forest classifier on train data
    y_predict = pipeline.predict_proba(train)[:,1]
    auc = roc_auc_score(labels_train, y_predict)
    print('AUC on train:', auc)

    # Evalute random forest classifier on test data
    y_predict = pipeline.predict(test)
    f1 = f1_score(labels_test, y_predict)
    print('F1 on test:', f1)

    # Evalute random forest classifier on test data
    y_predict = pipeline.predict_proba(test)[:,1]
    auc = roc_auc_score(labels_test, y_predict)
    print('AUC on test:', auc)


    # In[53]:

    import seaborn as sns
    get_ipython().magic('matplotlib inline')

    print(labels_test.mean())

    sns.distplot(y_predict)


    # In[54]:

    # Use LIME to explain individual predictions, initialize explainer object
    explainer = LimeTabularExplainer(
        train,
        class_names=['BrokeUp', 'StayedTogether'],
        feature_names=list(data.columns),
        categorical_features=categorical_idx,
        categorical_names=categorical_names,
        discretize_continuous=True
    )


    # In[55]:

    # Explain a prediction ("local interpretability"):
    # Now we see that the pipeline that takes raw data and returns the prediction
    # of the trained model now comes in conveniently.
    example = 3
    exp = explainer.explain_instance(test[example], pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[56]:

    # Explain another prediction ("local interpretability"):
    example = 13
    exp = explainer.explain_instance(test[example], pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[57]:

    # and we see differences in explaining the model's predictions.


    # In[58]:

    # Using LIME for for relationship management (not advised): Current chance of relationship success.
    current = [34, 36, 2, 0, 1, 0, 1, 0, 0, 0, 18, 0, 2, 0, 8, 4, 0, 0]
    exp = explainer.explain_instance(np.array(current), pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[59]:

    # Should I ask for a pay increase? It doesn't matter much.
    increase_income = [34, 36, 2, 0, 1, 0, 1, 0, 0, 0, 6, 0, 2, 0, 8, 4, 0, 0]
    exp = explainer.explain_instance(np.array(increase_income), pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[60]:

    # Should I buy a house? Maybe?
    buy_house = [34, 36, 2, 0, 1, 0, 1, 0, 0, 0, 6, 0, 1, 0, 8, 4, 0, 0]
    exp = explainer.explain_instance(np.array(buy_house), pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[61]:

    # Really, it's best to get married.
    get_married = [34, 36, 2, 0, 1, 0, 2, 0, 0, 0, 6, 0, 1, 0, 8, 4, 0, 0]
    exp = explainer.explain_instance(np.array(get_married), pipeline.predict_proba, num_features=10)
    print('Couples probability of staying together:', exp.predict_proba[1])
    exp.as_pyplot_figure()


    # In[ ]:
