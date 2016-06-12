
from mlexp import *
from evolutionary_search import EvolutionaryAlgorithmSearchCV
from sklearn.base import ClassifierMixin
from sys import stderr


class DEAPExperiment(MLExperiment):

    default_genetic_params = {
        'population_size': 40,
        'gene_mutation_prob': 0.15,
        'gene_crossover_prob': 0.5,
        'tournament_size': 5,
        'generations_number': 2
    }

    def __init__(self, transformer,
                 grid,
                 genetic_params=dict()):
        self.grid = grid
        self.genetic_params = self.default_genetic_params.copy()
        self.genetic_params.update(genetic_params)

        super(DEAPExperiment, self).__init__(transformer)


class DEAPSplitExperiment(DEAPExperiment, SplitExperiment):

    def __init__(self, transformer, grid, genetic_params,
                 test_prop=0.2):
        self.test_prop = test_prop
        super(DEAPSplitExperiment, self).__init__(
            transformer, grid, genetic_params)

    def experiment(self, X, target):

        self.prepare(X, target)

        bigX = self.X_train.append(self.X_test)
        bigY = self.y_train.append(self.y_test)
        train_max = self.X_train.shape[0]
        test_max = self.X_test.shape[0]
        bigFold = (np.arange(train_max),
                   np.arange(train_max, train_max + test_max))

        stderr.write(("Searching with train %d / test %d\n" +
                      "with params grid %s\n" +
                      "on genetic params %s\n\n") % (
                          train_max, test_max,
                          str(self.grid),
                          str(self.genetic_params)))

        self.cv = EvolutionaryAlgorithmSearchCV(estimator=self.learner,
                                                params=self.grid,
                                                scoring="roc_auc",
                                                cv=[bigFold],
                                                verbose=4,
                                                **self.genetic_params
                                                )

        self.cv.fit(bigX, bigY)

        return self


class DEAPSplitXgboostExperiment(DEAPSplitExperiment):

    def __init__(self, transformer,
                 grid,
                 genetic_params=dict(),
                 test_prop=0.2,
                 num_rounds=10):
        self.num_rounds = num_rounds
        super(DEAPSplitXgboostExperiment, self).__init__(
            transformer, grid, genetic_params, test_prop)

    def prepare(self, X, target):

        super(DEAPSplitXgboostExperiment, self).prepare(X, target)

        self.learner = xgb.XGBClassifier(n_estimators=self.num_rounds,
                                         nthread=4)

        return self
