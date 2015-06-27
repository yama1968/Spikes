# -*- coding: utf-8 -*-
"""
Created on Wed Jun 24 19:15:56 2015

@author: yannick
"""

import pymc
import numpy as np

n = 5*np.ones(4, dtype=int)
x = np.array([-0.86, -0.3, -0.05, 0.73])

alpha = pymc.Normal("alpha", mu=0, tau=0.01)
beta = pymc.Normal("beta", mu=0, tau=0.01)

@pymc.deterministic
def theta(a=alpha, b=beta):
    """theta = logit-1}(a+b)"""
    return pymc.invlogit(a+b*x)
    
d = pymc.Binomial("d", n=n, p=theta, value=np.array([0.,1.,3.,5.]),
                  observed=True)

