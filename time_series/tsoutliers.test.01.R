
# http://www.jalobe.com:8080/blog/tsoutliers/

library("tsoutliers")

Sys.setlocale("LC_TIME", "C")

data("bde9915")
gipi <- log(bde9915$gipi)
ce <- calendar.effects(gipi)

ts.plot(gipi)

res1 <- tso(y = gipi, xreg = ce, cval = 3.5, 
            types = c("AO", "LS", "TC", "SLS"), maxit = 1, 
            remove.method = "bottom-up", tsmethod = "arima", 
            args.tsmethod = list(order = c(0, 1, 1), 
                                 seasonal = list(order = c(0, 1, 1))))

print(res1)

d <- decompose(gipi)
plot(d)


