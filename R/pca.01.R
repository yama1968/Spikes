
# Load data
data(iris)
head(iris, 3)

require(ggplot2)

print(ggplot(iris, aes(Sepal.Length)) + geom_bar(binwidth=0.2))
print(ggplot(iris, aes(Sepal.Width)) + geom_bar(binwidth=0.2))
print(ggplot(iris, aes(Petal.Length)) + geom_bar(binwidth=0.2))
print(ggplot(iris, aes(Petal.Width)) + geom_bar(binwidth=0.2))

# log transform 
log.ir <- log(iris[, 1:4])
ir.species <- iris[, 5]
 
# apply PCA - scale. = TRUE is highly 
# advisable, but default is FALSE. 
ir.pca <- prcomp(log.ir,
                 center = TRUE,
                 scale = TRUE) 

print(ir.pca)
print(summary(ir.pca))
plot(ir.pca, type = "l")

# Predict PCs
p <- predict(ir.pca, 
             newdata=tail(log.ir, 2))
print (p)

# library(devtools)
# install_github("ggbiplot", "vqv")

library(ggbiplot)
g <- ggbiplot(ir.pca, obs.scale = 1, var.scale = 1, 
              groups = ir.species, ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)

require(caret)
trans = preProcess(iris[,1:4], 
                   method=c("BoxCox", "center", 
                            "scale", "pca"))
print(trans)

PC = predict(trans, iris[,1:4])
print (head(PC))


