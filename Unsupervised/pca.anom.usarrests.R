
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


###

library(dplyr)

fitted.comp <- fitted(k)

centered.comp <- (comp - fitted.comp) %>%
  mutate(cluster = clusters,
         state = rownames(USArrests))

clusters.sd <- centered.comp %>%
  group_by(cluster) %>%
  summarize(s1 = sd(PC1),
            s2 = sd(PC2),
            s3 = sd(PC3),
            s4 = sd(PC4))

norm.comp <- centered.comp %>%
  left_join(clusters.sd, by="cluster") %>%
  mutate(PC1 = PC1 / s1,
         PC2 = PC2 / s2,
         PC3 = PC3 / s3,
         PC4 = PC4 / s4) %>%
  mutate(d = sqrt((PC1*PC1 + PC2*PC2 + PC3*PC3 + PC4*PC4) / 4)) %>%
#  mutate(d = sqrt((PC1*PC1 + PC2*PC2) / 2)) %>%
  group_by(cluster) %>%
  mutate(q90 = quantile(d, .9),
         q75 = quantile(d, .75),
         da  = mean(d),
         dm  = median(d)) %>% 
  mutate(dr  = d/da) %>%
  ungroup()

qplot(cluster, d, data=norm.comp, geom="boxplot")
qplot(cluster, dr, data=norm.comp, geom="boxplot")
qplot(cluster, d/q75, data=norm.comp, geom="boxplot")


norm.comp %>% arrange(desc(d/q75))

g <- qplot(UrbanPop, Murder, data=USArrests, 
           colour=clusters,
           size=norm.comp$dr) +
  geom_text(aes(label = norm.comp$state), hjust = 0, vjust = -1)
print(g)

for (c1 in 1:3)
  for (c2 in (c1+1):4) {
    g <- qplot(USArrests[c1], USArrests[c2],
               colour=clusters,
               size=norm.comp$dr,
               xlab=colnames(USArrests)[c1],
               ylab=colnames(USArrests)[c2])
    print(g)
  }

