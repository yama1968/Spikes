#

library(ggplot2)
library(nlme)

source("helper.R")

set.seed(1234)

n <- 100

z <- w <- rnorm(n, sd = 20)
for (t in 2:n) z[t] <- z[t-1] * 0.8 + w[t]
Time <- 1:n
x <- 50 + 3 * Time + z
ggplot(data = data.frame(x = Time, y = x),
       aes(x, y)) + 
    geom_line() +
    xlab("time") +
    geom_smooth(method = "glm")

ggplot(data = data.frame(x = x, y = w), aes(y)) +
    geom_bar(stat = "bin", binwidth = 3)

x.lm <- lm(x ~ Time)
summary(x.lm)

www <- download.if.needed("global.dat")
Global <- scan(www)
Global.ts <- ts(Global, start = c(1856, 1), end = c(2005, 12), frequency = 12)
plot(Global.ts)
temp <- window(Global.ts, start = 1970)
plot(temp)
temp.lm <- lm(temp ~ time(temp))
summary(temp.lm)
confint(temp.lm)

ggplot(data = data.frame(a = time(temp), b = temp), aes(a,b)) + geom_line() + geom_smooth(method = "glm")
plot(decompose(temp))

acf(resid(temp.lm))
pacf(resid(temp.lm))

temp.gls <- gls(temp ~ time(temp), correlation = corAR1(0.7))
summary(temp.gls)
sqrt(diag(vcov(temp.gls)))
pacf(resid(temp.gls))
confint(temp.gls)


#

Seas <- cycle(temp)
Time <- time(temp)
temp.lm <- lm(temp ~ 0 + Time + factor(Seas))
summary(temp.lm)
confint(temp.lm)


