
data(USArrests)

library(caret)
library(ggplot2)

# We first get normalized and de-skewed data

trans = preProcess(USArrests, 
                   method=c("BoxCox",
                            "center", 
                            "scale"))
z <- predict(trans, USArrests)

# checking for normalization and de-skewing
summary(z)
sapply(z,sd)

# extracting components
pc <- prcomp(z, center=FALSE, scale=FALSE)
comp <- as.data.frame(predict(pc, z))

wss <- (nrow(comp)-1)*sum(apply(comp,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(comp, centers=i, nstart=100, iter.max=1000)$withinss)

qplot(x=1:15, y=wss, geom=c("point", "line"),
      xlab="Number of Clusters",
      ylab="Within groups sum of squares")

k <- kmeans(comp, 4, nstart=25, iter.max=1000)
clusters <- as.factor(k$cluster)

g <- qplot(PC1, PC2, data=comp,
           color=clusters)
print(g)

g <- qplot(x=clusters,
           y=USArrests$Murder,
           geom="boxplot")
print(g)

g <- qplot(UrbanPop, Murder, data=USArrests, colour=clusters)
print(g)

# outlier calculation with h2o

library(h2o)

l.h2o <- h2o.init(nthreads = 4)

x.h2o <- as.h2o(USArrests)

ae <- h2o.deeplearning(x               = names(USArrests),
                       training_frame  = x.h2o,
                       autoencoder     = TRUE,
                       hidden          = c(20, 2, 20),
                       activation      = "Tanh",
                       l2              = 1e-4,
                       epochs          = 50)
summary(ae)

x.anon <- as.data.frame(h2o.anomaly(ae, x.h2o))

qplot(Reconstruction.MSE, data = x.anon, geom="histogram", bins=40)

x.err <- x.anon$Reconstruction.MSE
threshold <- quantile(x.err, .8)

ae.outlier <- x.anon$Reconstruction.MSE > threshold

g <- qplot(UrbanPop, Murder, data=USArrests,
           colour=clusters,
           size=ae.outlier)
print(g)

g <- qplot(UrbanPop, Murder, data=USArrests,
           colour=clusters,
           size=x.err) +
  geom_text(aes(label = rownames(USArrests)), hjust = 0, vjust = -1)
print(g)


deep <- as.data.frame(h2o.deepfeatures(ae, data=x.h2o, layer=2))

g <- qplot(DF.L2.C1, DF.L2.C2, data = deep,
           colour=clusters,
           size=x.err)
print(g)

print(rownames(USArrests[ae.outlier,]))

library(dplyr)

x <- USArrests %>% 
  mutate(err = x.err,
         state = rownames(USArrests),
         cluster = clusters) %>% 
  arrange(desc(x.err))

x
