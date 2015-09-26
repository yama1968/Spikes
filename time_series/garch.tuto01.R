

# http://yunus.hacettepe.edu.tr/~iozkan/eco665/archgarch.html

oil<-read.csv("http://yunus.hacettepe.edu.tr/~iozkan/data/oilcsv.csv", header=T, sep=";")

head(oil)

library(zoo)
oil <- oil[,-4]
oil.zoo <- zoo(oil[,-1],
               order.by=as.Date(strptime(as.character(oil[,1]), "%d.%m.%Y")))
plot(oil.zoo, main="Brent and Crude Price Series")

xu100<-read.csv("http://yunus.hacettepe.edu.tr/~iozkan/data/endXU100.csv", header=T, sep=";")
head(xu100)
usd<-read.csv("http://yunus.hacettepe.edu.tr/~iozkan/data/usd.csv", header=T, sep=";")
head(usd)

#install.packages("chron")
library(chron)

xu100 <- xu100[xu100[,"SESSION"]!=1,-c(1,3,4,5)]

# now convert to zoo
xu100.zoo=zoo(xu100[,-1], order.by=as.Date(strptime(as.character(xu100[,1]), "%d.%m.%Y")))
colnames(xu100.zoo) <- c("Close", "USD", "Euro")

plot(xu100.zoo)

usd.zoo=zoo(usd[,-1], order.by=as.Date(strptime(as.character(usd[,1]), "%d.%m.%Y")))
usd <- usd.zoo[!is.weekend(time(usd.zoo))]
plot(usd, main="TL/USD Series", xlab="Date")

# rolling window
plot(rollapply(xu100.zoo, width=120, mean, na.rm=T), main="Mean of Rolling 120 Obs.")

library(forecast)
# Ok.. Lets play with our data..
# Need ts object for forecast
xucl <- na.approx(na.trim(xu100.zoo[,"Close"], side="both"))
head(to.weekly(xucl))

xucl.w <- to.weekly(xucl)[,"xucl.Close"]
# A dirty weekly close oil as time series.. beware!!!!
start(xucl.w)

xucl.wts <- ts(xucl.w, start=c(1988,1,8), freq=52)

# 
plot(log(xucl.wts), main="Log of BIST100 Index")

a <- auto.arima(log(xucl.wts), parallel=TRUE)
print (a)
tsdiag(a)
a2 <- arima(log(xucl.wts), order=c(1,1,1))
print(a2)
tsdiag(a2)

# Now garch

require(rmgarch)
require(PerformanceAnalytics)

# Lets use usd series.. starting from 2007
usd1 <- window(usd, start="2007-01-01")

# Remove NA's
usd1 <- na.approx(na.trim(CalculateReturns(usd1), side="both"))

# start with default GARCH spec.
spec = ugarchspec()
print(spec)

def.fit = ugarchfit(spec = spec, data = usd1)
print(def.fit)

# big garch

garch11.spec = ugarchspec(mean.model = list(armaOrder = c(0,0)), 
                          variance.model = list(garchOrder = c(1,1), 
                                                model = "sGARCH"), distribution.model = "norm")

# Fit the model
garch.fit = ugarchfit(garch11.spec, data = usd1, fit.control=list(scale=TRUE))

print(garch.fit)
plot(garch.fit, which = 1)
plot(garch.fit, which = 3)


