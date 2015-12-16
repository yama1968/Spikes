#

library(mixtools)

data(faihtful)
attach(faithful)

hist(waiting, main="Time between Old Faithful eruptions",
     xlab="Minutes", ylab="", cex.main=1.5, cex.lab=1.5, cex.axis=1.4)

wait1 <- normalmixEM(waiting, lambda = .5, mu = c(55, 80), sigma = 5)
summary(wait1)

plot(wait1, density=TRUE, cex.axis=1.4, cex.lab=1.4, cex.main=1.8,
     main2="Time between Old Faithful eruptions", xlab2="Minutes")

wait1[c("lambda", "mu", "sigma")]

wait2 <- normalmixEM(waiting, lambda = 0.5)
plot(wait2, density = T)
wait2[c("lambda", "mu", "sigma")]
