
library(quantmod)
library(fArma)

getSymbols("^GSPC", from="2000-01-01")

gspcRets = diff(log(Cl(GSPC)))
gspcTail = as.ts(tail(gspcRets, 500))

gspcArma = armaFit(formula=~arma(2,2), data=gspcTail)

summary(gspcArma)
 
# gspcArma = armaFit(formula=~arma(2,2), data=gspcRets)

library(forecast)

best <- auto.arima(x=gspcTail,
                   max.p=7, max.q=7,
                   stepwise=FALSE,
                   ic="aic")
summary(best)
plot(forecast(best, h=20))

m51 = armaFit(formula=~arma(5,1), data=gspcTail)
summary(m51)

