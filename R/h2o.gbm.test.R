require("h2o")

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
