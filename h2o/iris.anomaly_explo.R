library(h2o)
library(ggplot2)

localH2O <- h2o.init(nthreads=-1)

iris.h2o <- as.h2o(iris, "iris")

train.dl <- function(data       = iris.h2o,
                     label      = iris$Species,
                     l2         = 0.01,
                     hidden     = c(20, 30, 20),
                     max_w2     = 1e-4,
                     print      = TRUE,
                     plot       = TRUE) {

    iris.dl <- h2o.deeplearning(x                  = 1:3,
                                training_frame     = data,
                                autoencoder        = T,
                                activation         = "Tanh",
                                l2                 = l2,
                                hidden             = hidden,
                                max_w2             = max_w2,
                                epochs             = 200,
                                seed               = 1234)

    if (print) print(iris.dl)

    if (plot) {
        iris.anon <- as.data.frame(h2o.anomaly(iris.dl, data))

        features <- as.data.frame(h2o.deepfeatures(iris.dl, data, layer = 3))
        features$label <- label

        print(qplot(DF.L3.C1, DF.L3.C2,
                    data    = features,
                    color   = label,
                    main    = "C1 vs C2",
                    size    = I(5),
                    alpha   = 0.5))

        if (hidden[2] >= 3) {

          print(qplot(DF.L3.C1, DF.L3.C3,
                      data    = features,
                      color   = label,
                      main    = "C1 vs C3",
                      size    = I(5),
                      alpha   = 0.5))

          print(qplot(DF.L3.C2, DF.L3.C3,
                      data    = features,
                      color   = label,
                      main    = "C2 vs C3",
                      size    = I(5),
                      alpha   = 0.5))

        }
    }

    iris.dl
}

# train.dl(hidden=c(10,20,10), l2=1e-3, max_w2=NULL)
# dl <- train.dl(hidden = c(10,20,10), l2 = NULL, max_w2 = 1)

train.dl(hidden = c(20,3,20), l2 = 0.001, max_w2 = NULL)
train.dl(hidden = c(20, 20, 3, 20, 20), l2 = 0.0001, max_w2 = NULL)

