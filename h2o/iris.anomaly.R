library(h2o)

localH2O <- h2o.init(nthreads=-1)
data(iris)
View(iris)

iris.h2o <- as.h2o(iris, "iris")

iris.dl <- h2o.deeplearning(x=1:3,
                            training_frame=iris.h2o,
                            autoencoder=T,
                            activation="Tanh",
                            l2=0.0001,
                            hidden=c(20, 10, 2, 10, 20),
                            epochs=200)
print(iris.dl)
iris.anon <- as.data.frame(h2o.anomaly(iris.dl, iris.h2o))

iris$rmse <- iris.anon$Reconstruction.MSE

hist(iris$rmse)

head(iris,10)

######

features <- as.data.frame(h2o.deepfeatures(iris.dl, iris.h2o, layer = 3))
features$label <- iris$Species

library(ggplot2)

qplot(DF.L3.C1, DF.L3.C2,
      data    = features,
      color   = label,
      main    = "C1 vs C2")

