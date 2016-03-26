
import numpy as np

def step(*shape):
    # Create random vector with +1 or -1
    return (2 * (np.random.random_sample(shape) < 0.5) - 1)

def simulate(iterations, n=10000):
    s = step(iterations, n)
    x = np.cumsum(s, axis=0)
    bins = np.arange(-30, 30, 1)
    y = np.vstack([np.histogram(x[i,:], bins)[0]
                  for i in range(iterations)])
    return y