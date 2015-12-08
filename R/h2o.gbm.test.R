require("h2o")
require(ggplot2)

if (!require(vcd)) {
  install.packages('vcd') #Available in Cran. Used for its dataset with categorical values.
  require(vcd)
}

data(Arthritis)

df <- Arthritis
df$AgeFactor <- as.factor(10 * (df$Age %/% 10))
df$target    <- as.factor(df$Improved == "Marked")
df$Improved  <- NULL

localH2O <- h2o.init(nthreads=-1)

df.hex <- as.h2o(df, "Arthritis")

model <- h2o.gbm(y                = "target", 
                 x                = c("Treatment","AgeFactor","Sex"),
                 training_frame   = df.hex,
                 distribution     = "bernoulli",
                 max_depth        = 3,
                 nfolds           = 4,
                 ntrees           = 20,
                 balance_classes  = FALSE,
                 seed             = 1234)

print(model)

h2o.varimp(model)
h2o.confusionMatrix(model)

dl.model <- h2o.deeplearning(y                = "target", 
                             x                = c("Treatment","AgeFactor","Sex"),
                             training_frame   = df.hex,
                             hidden           = c(10, 10, 10, 10),
                             nfolds           = 4,
                             epochs           = 10,
                             variable_importance = TRUE,
                             seed             = 1234)
print(dl.model)
h2o.varimp(dl.model)

#####

ae.model <- h2o.deeplearning(x                = c("Treatment","AgeFactor","Sex"),
                             autoencoder      = T,
                             training_frame   = df.hex,
                             hidden           = c(20, 5, 2, 5, 20),
                             epochs           = 100,
                             variable_importance = TRUE,
                             seed             = 1234)

features <- as.data.frame(h2o.deepfeatures(ae.model, df.hex, layer = 3))

library(ggplot2)

qplot(as.data.frame(h2o.anomaly(ae.model, df.hex))$Reconstruction.MSE, 
      geom = "histogram",
      fill = I("green"))

qplot(DF.L3.C1, DF.L3.C2,
      data    = features,
      color   = Arthritis$Improved,
      main    = "C1 vs C2")

