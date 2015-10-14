
#

library(ggplot2)

set.seed(1)
df <- data.frame(x=1:100, y=rnorm(100)); ggplot(df, aes(x,y)) + geom_line() + geom_smooth(method='loess')

ggplot(df, aes(y)) + 
    geom_histogram(col=I("red"), fill=I("blue"), alpha=I(.2), binwidth=0.2)

set.seed(2)
acf(rnorm(100))
print(sd(rnorm(100)))

w <- rnorm(100)
d <- (decompose(ts(w, frequency = 10)))
plot(d)
print (sd(w)); print(sd(d$random, na.rm=T))


foo <- (1:20)*2
print (str(diff(foo)))

x <- w <- rnorm(1000)
x <- cumsum(w)
print(str(x))
plot(x, type='l')
acf(x)
acf(diff(x))

###

data("sunspot.month")
sunspot.ar <- ar(window(sunspot.year, end=1950))
sunspot.ar
a <- predict(sunspot.ar, n.ahead = 50)
ts.plot(sunspot.year, 
        a$pred + 2 * a$se, a$pred, a$pred - 2 * a$se, 
        lty = c(1, 3, 3, 2))
ts.plot(sunspot.year, 
        qpois(0.05, a$pred), qpois(.95, a$pred),
        lty = c(1, 3, 3, 2))




