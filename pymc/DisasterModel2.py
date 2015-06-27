from pymc import DiscreteUniform, Exponential, deterministic, Poisson, Uniform, Impute
import numpy as np

disasters_array =   np.array([ 4, 5, 4, 0, 1, 4, 3, 4, 0, 6, 3, 3, 4, 0, 2, 6,
                   3, 3, 5, 4, 5, 3, 1, 4, None, 1, 5, 5, 3, None, 2, 5,
                   2, 2, 3, 4, 2, 1, 3, 2, 2, None, 1, 1, 1, 3, 0, 0,
                   1, 0, 1, 1, 0, None, 3, None, 0, 3, 2, 2, 0, 1, 1, 1,
                   0, 1, 0, 1, 0, 0, 0, 2, 1, 0, 0, 0, 1, 1, 0, 2,
                   3, 3, 1, 1, 2, 1, 1, 1, 1, 2, 4, 2, 0, 0, 1, 4,
                   0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1])

from numpy.random import randint

for i in randint(0, len(disasters_array)-1, len(disasters_array)/3):
    disasters_array[i] = None
    
print disasters_array

s = DiscreteUniform("s", lower=0, upper=110, doc='Switchpoint[year]')
e = Exponential("e", beta=1)
l = Exponential("l", beta=1)

masked_data = np.ma.masked_equal(disasters_array, value=None)

@deterministic(plot=False)
def r(s=s, e=e, l=l):
    """ Concatenate Poisson means """
    out = np.empty(len(disasters_array))
    out[:s] = e
    out[s:] = l
    return out

D = Poisson("D", value=masked_data, mu=r, observed=True)
