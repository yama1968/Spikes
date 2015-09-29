
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
