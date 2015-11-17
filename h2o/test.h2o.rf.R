
require("h2o")
require("cvAUC")
require("parallel")

localH2O = h2o.init(nthreads = 2)

prostate.hex = h2o.importFile(localH2O, path =
                                "https://raw.github.com/0xdata/h2o/master/smalldata/logreg/prostate.csv",
                              destination_frame = "prostate.hex")
model <- h2o.randomForest(y = "CAPSULE", x = c("AGE","RACE","PSA","DCAPS"),
                 training_frame = prostate.hex, family = "binomial", nfolds = 7)

model
