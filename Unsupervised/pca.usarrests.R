

data(USArrests)

pc <- prcomp(USArrests, center=TRUE, scale=TRUE)

comp <- predict(pc, USArrests)

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

#
pc.bad <- prcomp(USArrests, center=TRUE, scale=FALSE)
summary(pc.bad)


# robust PCA
library(amap)

robust <- acprob(USArrests, center=TRUE, reduce=TRUE)
print(robust)

kr <- kmeans(robust$scores, 4, nstart=25, iter.max = 1000)
g <- qplot(UrbanPop, Murder, data=USArrests, colour=factor(kr$cluster))
print(g)

# sum of squares
ss <- function(x) sum(scale(x, scale = FALSE)^2)
rss <- function(x) sqrt(rowSums(x^2))

x <- USArrests

## cluster centers "fitted" to each obs.:
fitted.x <- fitted(k);  head(fitted.x)
resid.x <- x - fitted(k)

dists <- rss(resid.x)

avg.dists <- rowsum(dists, k$cluster) / rowsum(rep(1, length(k$cluster)), k$cluster)

boxplot(dists ~ k$cluster)

