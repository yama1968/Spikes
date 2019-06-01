
library(horserule)
data(Boston, package = "MASS")

N = nrow(Boston)
train = sample(1:N, 500)
Xtrain <- Boston[train, -14]
ytrain <- Boston[train, 14]
Xtest <- Boston[-train, -14]
ytest <- Boston[-train, 14]

lin <- 1:13

system.time(
  hrres <- HorseRuleFit(X = Xtrain, y = ytrain,
                        thin = 1, niter = 1000, burnin = 100,
                        L = 3, S = 6, ensemble = "both", mix = 0.3, ntree = 100,
                        intercept = F, linterms = lin, ytransform = "log",
                      alpha = 1, beta = 2, linp = 1, restricted = 0)
)

pred <- predict(hrres, Xtest)
print(sqrt(mean((pred - ytest)^2)))

importance_hs(hrres)
Variable_importance(hrres)
