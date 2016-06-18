#

library(rethinking)
library(xda)
library(ggplot2)
library(plotly)

# Getting data

data(reedfrogs)
d <- reedfrogs

str(d)

# Plotting

qplot(d$surv, geom = "histogram")
qplot(propsurv, data = d, geom = "histogram", binwidth = 0.1)

qplot(propsurv, data = d, 
      fill = as.factor(density),
      alpha = 0.2,
      geom = "histogram", 
      binwidth = 0.1)

qplot(as.factor(density), surv, data = d, geom = "boxplot")

# First very simple model: variable intercept

d$tank <- 1:nrow(d)

m12.1 <- map2stan(
  alist(
    surv               ~ dbinom(density, p),
    logit(p)          <- a_tank[tank],
    a_tank[tank]       ~ dnorm(0, 5)
  ),
  data    = d,
  cores   = 4
)

precis(m12.1, depth=2)

ggplot(data=d, aes(x = m12.1@coef)) + geom_histogram(binwidth = 0.5, colour="white") + facet_grid(size~.)
ggplotly()


# Second model: tank alpha from same distribution

m12.2 <- map2stan(
  alist(
    surv               ~ dbinom(density, p),
    logit(p)          <- a_tank[tank],
    a_tank[tank]       ~ dnorm(alpha, sigma),
    alpha              ~ dnorm(0, 1),
    #sigma              ~ dcauchy(0,1)
    sigma               ~ dexp(1)
  ),
  data    = d,
  iter    = 4000,
  chains  = 4,
  cores   = 4
)

summary(m12.2)

# Comparison

compare(m12.1, m12.2)

post <- extract.samples(m12.2)

d$propsurv.est <- logistic(apply(post$a_tank, 2, median))

plot(d$propsurv, ylim = c(0,1),
     pch = 16, xaxt = "n",
     xlab = "tank",
     ylab = "proportion survival",
     col = rangi2)
axis(1, at=c(1,16,32,48,labels=c(1,16,32,48)))

points(d$propsurv.est)
abline(h=logistic(median(post$alpha)), lty=2)
abline(v=16.5, lwd=0.5)
abline(v=32.5, lwd=0.5)
text(8, 0, "small tanks")
text(16+8, 0, "medium tanks")
text(32+8, 0, "large tanks")

