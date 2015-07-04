# 1. Priors
thetas = [pymc.Beta('theta_%i' % i, 30, 10) for i in [0,1]]

# 2. Likelihood
second_shot_missed_first = [pymc.Bernoulli('shot0_%i' % i, p=thetas[0], value=result, observed=True) 
                            for i, result in enumerate(missed_first)]

second_shot_made_first   = [pymc.Bernoulli('shot1_%i' % i, p=thetas[1], value=result, observed=True) 
                            for i, result in enumerate(made_first)]

# 3. PyMC model
model = pymc.Model(thetas, second_shot_missed_first, second_shot_made_first)
mcmc = pymc.MCMC(model)
mcmc.sample(iter=5000, burn=1000, thin=10)

# 4. Extract traces
theta_0_trace = mcmc.trace('theta_0')[:]
theta_1_trace = mcmc.trace('theta_1')[:]
