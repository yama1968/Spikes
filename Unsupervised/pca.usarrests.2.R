
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

k <- kmeans(comp, 5, nstart=25, iter.max=1000)
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


# sum of squares
ss <- function(x) sum(scale(x, scale = FALSE)^2)
rss <- function(x) sqrt(rowSums(x^2))

## cluster centers "fitted" to each obs.:
resid.comp <- comp - fitted(k)

dists <- rss(resid.comp)

avg.dists <- rowsum(dists, k$cluster) / rowsum(rep(1, length(k$cluster)), k$cluster)

g <- qplot(clusters, dists, geom="boxplot")
print(g)

is.outlier <- rep(FALSE, length(k$cluster))
for (i in 1:length(k$cluster))
  is.outlier[[i]] <- (dists[[i]] > 1.3 * avg.dists[[k$cluster[[i]]]])

g <- qplot(UrbanPop, Murder, data=USArrests, colour=factor(k$cluster), size=is.outlier)
print(g)

g <- qplot(PC1, PC2, data=comp, colour=factor(k$cluster), size=is.outlier)
print(g)

print(rownames(USArrests)[is.outlier])

###

x2 <- USArrests[! is.outlier,]
trans2 = preProcess(x2, 
                   method=c("BoxCox", "center", 
                            "scale"))
z2 <- predict(trans2, x2)

pc2 <- prcomp(z2, center=FALSE, scale=FALSE)
comp2 <- predict(pc2, z2)

k2 <- kmeans(comp2, 4, nstart=25, iter.max=1000)

boxplot(x2$Murder ~ k2$cluster, 
        xlab='Cluster', ylab='Murder', 
        main='Murder by Cluster')

g <- qplot(UrbanPop, Murder, data=x2, colour=factor(k2$cluster))
print(g)

##

for (c in colnames(USArrests)) {
  g <- qplot(clusters, USArrests[,c],
             geom = "boxplot",
             ylab = c)
  print(g)
}

