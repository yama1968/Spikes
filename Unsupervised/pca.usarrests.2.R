
data(USArrests)

library(caret)

trans = preProcess(USArrests, 
                   method=c("BoxCox", "center", 
                            "scale", "pca"))
z <- predict(trans, USArrests)

pc <- prcomp(z, center=FALSE, scale=FALSE)
comp <- predict(pc, z)

wss <- (nrow(comp)-1)*sum(apply(comp,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(comp, centers=i, nstart=100, iter.max=1000)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

k <- kmeans(comp, 4, nstart=25, iter.max=1000)
library(RColorBrewer)
library(scales)
palette(alpha(brewer.pal(9,'Set1'), 0.5))
plot(comp, col=k$clust, pch=16)

boxplot(USArrests$Murder ~ k$cluster, 
        xlab='Cluster', ylab='Murder', 
        main='Murder by Cluster')
boxplot(USArrests$Rape ~ k$cluster, 
        xlab='Cluster', ylab='Murder', 
        main='Murder by Cluster')

library(ggplot2)

g <- qplot(UrbanPop, Murder, data=USArrests, colour=factor(k$cluster))
print(g)


# sum of squares
ss <- function(x) sum(scale(x, scale = FALSE)^2)
rss <- function(x) sqrt(rowSums(x^2))

## cluster centers "fitted" to each obs.:
fitted.z <- fitted(k);  head(fitted.z)
resid.z <- z - fitted(k)

dists <- rss(resid.z)

avg.dists <- rowsum(dists, k$cluster) / rowsum(rep(1, length(k$cluster)), k$cluster)

boxplot(dists ~ k$cluster)

is.outlier <- rep(FALSE, length(k$cluster))
for (i in 1:length(k$cluster))
  is.outlier[[i]] <- (dists[[i]] > 1.4 * avg.dists[[k$cluster[[i]]]])

g <- qplot(UrbanPop, Murder, data=USArrests, colour=factor(k$cluster), size=is.outlier)
print(g)

g <- qplot(PC1, PC2, data=z, colour=factor(k$cluster), size=is.outlier)
print(g)

print(rownames(USArrests)[is.outlier])

###

x2 <- USArrests[! is.outlier,]
trans2 = preProcess(x2, 
                   method=c("BoxCox", "center", 
                            "scale", "pca"))
z2 <- predict(trans2, x2)

pc2 <- prcomp(z2, center=FALSE, scale=FALSE)
comp2 <- predict(pc2, z2)

k2 <- kmeans(comp2, 4, nstart=25, iter.max=1000)

boxplot(x2$Murder ~ k2$cluster, 
        xlab='Cluster', ylab='Murder', 
        main='Murder by Cluster')

g <- qplot(UrbanPop, Murder, data=x2, colour=factor(k2$cluster))
print(g)

