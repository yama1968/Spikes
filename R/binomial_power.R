#
# power test for binomial variables

library(Hmisc)

bpower.sim(0.2, 0.6,
           n1 =  1000,
           n2 = 10000,
           alpha = 0.005)

bsamsize(0.2, 0.6, fraction=.1, alpha=0.01, power=.99)
