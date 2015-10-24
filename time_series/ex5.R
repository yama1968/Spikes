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

##

SIN <- COS <- matrix(nrow = length(Time), ncol = 6)
for (i in 1:6) {
    COS[, i] <- cos(2 * pi * i * Time / 12)
    SIN[, i] <- sin(2 * pi * i * Time / 12)
}

Time <- (time(temp) -mean(time(temp)))/sd(time(temp))

temp.lm1 <- lm(temp ~ Time + I(Time ^2) + COS[, 1] + SIN[, 1] +
                   COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] + COS[, 4] + SIN[, 4] +
                   COS[, 5] + SIN[, 5] + COS[, 6] + SIN[, 6])
summary(temp.lm1)
AIC(temp.lm1)

temp.lm2 <- lm(temp ~ Time + COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] +
                   COS[, 6] + SIN[, 6])
summary(temp.lm2)
AIC(temp.lm2)

# the best fit for a linear model
temp.lm3 <- step(temp.lm1)
summary(temp.lm3)
AIC(temp.lm3)

plot(time(temp), resid(temp.lm3), type = "l")
acf(resid(temp.lm3))
pacf(resid(temp.lm3))

# fitting the residual on an AR time serie
res.ar <- ar(resid(temp.lm3), method = "mle")
res.ar

# check for autocorrelation in residual
acf(res.ar$res[-(1:2)])

temp.gls1 <- gls(temp ~ Time + I(Time ^2) + COS[, 1] + SIN[, 1] +
                    COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] + COS[, 4] + SIN[, 4] +
                    COS[, 5] + SIN[, 5] + COS[, 6] + SIN[, 6])
summary(temp.gls1)
acf(temp.gls1$residuals)

temp.gls2 <- gls(temp ~ Time + 
                     COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] + COS[, 4] + 
                     SIN[, 5] + SIN[, 6])
summary(temp.gls2)
acf(temp.gls2$residuals)


####################################################################################################
#
# on air passengers
#

data(AirPassengers)
AP <- AirPassengers
plot(AP)
plot(log(AP))

SIN <- COS <- matrix(nrow = length(AP), ncol = 6)
for (i in 1:6) {
    COS[, i] <- cos(2 * pi * i * time(AP))
    SIN[, i] <- sin(2 * pi * i * time(AP))
}
TIME <- (time(AP) - mean(time(AP)))/sd(time(AP))
mean(time(AP))

AP.lm1 <- lm(log(AP) ~ TIME + I(TIME ^2) + I(TIME ^3) + I(TIME ^4) + COS[, 1] + SIN[, 1] +
                   COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] + COS[, 4] + SIN[, 4] +
                   COS[, 5] + SIN[, 5] + COS[, 6] + SIN[, 6])
summary(AP.lm1)
AIC(AP.lm1)

AP.lm3 <- step(AP.lm1)
summary(AP.lm3)
AIC(AP.lm3)

acf(resid(AP.lm3))

AP.gls <- gls(log(AP) ~ TIME + I(TIME ^2) + COS[, 1] + SIN[, 1] +
                      COS[, 2] + SIN[, 2] + COS[, 3] + SIN[, 3] + COS[, 4] + SIN[, 4] +
                      SIN[, 5],
                  correlation = corAR1(0.6))
summary(AP.gls)

AP.ar <- ar(resid(AP.lm3), order = 1, method = "mle")
acf(AP.ar$res[-1])


# predicting

new.t <- time(ts(start = 1961, end = c(1970, 12), fr = 12))
TIME <- (new.t - mean(time(AP)))/sd(time(AP))

SIN <- COS <- matrix(nrow = length(new.t), ncol = 6)
for (i in 1:6) {
    COS[, i] <- cos(2 * pi * i * new.t)
    SIN[, i] <- sin(2 * pi * i * new.t)
}
SIN <- SIN[, -6]
new.dat <- data.frame(TIME = as.vector(TIME),
                      SIN  = SIN,
                      COS  = COS)
AP.pred.ts <- exp(ts(predict(AP.gls, new.dat), st = 1961, fr = 12))
ts.plot(log(AP), log(AP.pred.ts), lty = 1:2)
ts.plot(AP, AP.pred.ts, lty = 1:2)


