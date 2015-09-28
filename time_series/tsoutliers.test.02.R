
library(tsoutliers)

data(Nile)
resNile1 <- tso(y=Nile, types=c("AO", "LS", "TC"),
                tsmethod="stsm", args.tsmodel=list(model="local-level"))
print(resNile1)

r <- resNile1
points <-data.frame(x = r$outliers$time-1,
                    y = Nile[r$outliers$time-start(Nile)[[1]]])

foo <- data.frame(t = start(Nile):end(Nile),
                  n = Nile[1:100])

p <- ggplot(foo, aes(t, n)) + 
    geom_line() + xlab("") + ylab("Nile")

p <- p + geom_point(data = points, mapping=aes(x=x, y=y), 
                    shape=1, size=5, color="red")
p
