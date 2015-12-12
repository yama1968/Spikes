
require("h2o")
require("cvAUC")
require("parallel")

localH2O = h2o.init(nthreads = 2)

prostate.hex = h2o.importFile(path =
                                "https://raw.github.com/0xdata/h2o/master/smalldata/logreg/prostate.csv",
                              destination_frame = "prostate.hex")

prostate.hex$CAPSULE <- as.factor(prostate.hex$CAPSULE)

model <- h2o.glm(y = "CAPSULE", x = c("AGE","RACE","PSA","DCAPS"),
                 training_frame = prostate.hex, family = "binomial", alpha = 0.1,
                 nfolds = 7)

model

model <- h2o.gbm(y = "CAPSULE", x = c("AGE","RACE","PSA","DCAPS"),
                 training_frame = prostate.hex,
                 distribution = "bernoulli",
                 max_depth = 5,
                 nfolds    = 7,
                 ntrees    = 8)

model
