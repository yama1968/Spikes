#

from numpy.random import permutation
from sklearn import svm, datasets
from sacred import Experiment
ex = Experiment('iris_rbf_svm')


@ex.config
def cfg():
    C = 10
    gamma = 0.3


@ex.automain
def run(C, gamma):
    iris = datasets.load_iris()
    per = permutation(iris.target.size)
    iris.data = iris.data[per]
    iris.target = iris.target[per]
    clf = svm.SVC(C, 'rbf', gamma=gamma)
    clf.fit(iris.data[:90],
            iris.target[:90])
    return clf.score(iris.data[90:],
                     iris.target[90:])
