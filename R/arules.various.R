
# install.packages("arules")
# install.packages("discretization")

library(arules)
library(discretization)

data(iris)


disc <- mdlp(iris)
disc <- as.data.frame(lapply(disc$Disc.data, as.factor))
rules <- apriori(disc,
                 parameter = list(supp = 0.005, conf = 0.8),
                 appearance = list(rhs = c("Species=versicolor", "Species=setosa",
                                           "Species=virginica"),
                                   default = "lhs"))
inspect(rules)

subset.matrix <- is.subset(rules, rules)
subset.matrix[lower.tri(subset.matrix, diag = T)] <- NA
redundant <- colSums(subset.matrix, na.rm = T) >= 1
rules.pruned <- sort(rules[!redundant], by = "lift")
inspect(rules.pruned)

## compare

library(rpart)

iris.tree <- rpart("Species ~ .", data = iris)
iris.tree

##### Arthritis

library(vcd)
arth <- Arthritis[,-1]
arth$Age <- as.factor(round(arth$Age / 20))
rules <- sort(apriori(arth,
                      parameter = list(supp = 0.005, conf = 0.6),
                      appearance = list(rhs = c("Improved=Some", "Improved=Marked"),
                                        default = "lhs")), by = "lift")
inspect(rules)
