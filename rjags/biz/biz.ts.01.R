# biz as ts

biz <- c(rep(0.0,11),
         14.0,
         0.0, 0.0,
         34,
         5,
         25,
         225,
         0,0, 0,0,
         90,
         68,
         0,
         50,
         0,0,
         241,
         0, 50,0,0,0,0,
         5, 95, 0, 35)

biz <- ts(biz)

fit1 <- arima(biz, order = c(1, 0, 0))
tsdiag(fit1)
fit2 <- arima(biz, order = c(3, 3, 3))
tsdiag(fit2)
BIC(fit1, fit2)

d <- diff(biz)
biz.d.ar <- arima(d, order = c(2, 2, 2))
tsdiag(biz.d.ar)
