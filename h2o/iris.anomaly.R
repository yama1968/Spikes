library(h2o)

localH2O <- h2o.init(nthreads=-1)
data(iris)
View(iris)

iris.h2o <- as.h2o(localH2O, iris, "iris")

iris.dl <- h2o.deeplearning(x=1:3,
                            training_frame=iris.h2o,
                            autoencoder=T,
                            activation="tanh",
                            l2=0.001,
                            hidden=c(10,5),
                            epochs=1)
print(iris.dl)
iris.anon <- as.data.frame(h2o.anomaly(iris.dl, iris.h2o))
plot.ts(iris.anon)

iris$rmse <- iris.anon$Reconstruction.MSE

p <-as.data.frame(iris.dl, x=1:3, iris.h2o)
head(p,10)