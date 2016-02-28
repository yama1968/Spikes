#

import sklearn
from sys import stderr


class Transformer(object):

    def fit_transform(self, X, y=None):
        self.fit(X, y)
        return self.transform(X)


class KtPipe(Transformer):

    _transformers = dict()

    def __init__(self, trflist = []):
        self._trflist = trflist

    @classmethod
    def add(cls, **transformers):
        cls._transformers.update(transformers)

    @classmethod
    def from_json(cls, l):
        return cls([cls._transformers[k[0]](**k[1]) for k in l])

    @classmethod
    def get(cls):
        return cls._transformers.keys()


    def show(self):
        print(repr(self._trflist))

    def __repr__(self):
        return "KtPipe(%s)" % str([repr(p) for p in self._trflist])


    def fit_transform(self, X, y=None):

        Xt = X
        for t in self._trflist:
            Xt = t.fit_transform(Xt)
        return Xt


    def fit(self, X, y=None):
        
        self.fit_transform(X, y)


    def transform(self, X):
        Xt = X
        for t in self._trflist:
            Xt = t.transform(Xt)
        return Xt


class Test(Transformer):

    def __init__(self, name = "Test", *args, **kwargs):
        self._name = name
        self._args = args
        self._kwargs = kwargs


    def fit(self, X, y=None):
        stderr.write("Fitting for %s with args %s and kwargs %s.\n" % (self._name, str(self._args), str(self._kwargs)))

    def transform(self, X):
        stderr.write("Predicting for %s with args %s and kwargs %s.\n" % (self._name, str(self._args), str(self._kwargs)))
        return X

    def __repr__(self):
        return "Test(%s, %s, %s)" % (self._name, str(self._args), str(self._kwargs))


class Test_A(Test):

    def __init__(self):
        super().__init__("A")

    def transform(self, X):
        X[X.columns[0]] += 1
        return super().transform(X)
        
        
class Test_B(Test):

    def __init__(self, col, qty):
        self._col = col
        self._qty = qty
        super().__init__("B", col, qty)

    def transform(self, X):
        X[self._col] += self._qty
        return super().transform(X)
        

KtPipe.add(A=Test_A, B=Test_B)

