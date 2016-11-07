

load("titanic.raw.rdata")

library(arules)
rules <- apriori(titanic.raw)
inspect(rules)

rules <- apriori(titanic.raw,
                 parameter = list(minlen=1, maxlen=4, supp=0.005, conf=0.8),
                 appearance = list(rhs=c("Survived=No", "Survived=Yes"),
                                   default="lhs"),
                 control = list(verbose=F))
rules.sorted <- sort(rules, by="lift")
inspect(rules.sorted)

subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA

redundant <- colSums(subset.matrix, na.rm=T) >= 1
which (redundant)
rules.pruned <- rules.sorted[!redundant]
inspect(rules.pruned)

library(arulesViz)
plot(rules)

plot(rules, method="graph", control=list(type="items"))

