
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


###############################################

library(RJSONIO)
library(RCurl)
library(ggplot2)

page <- "FR"
raw_data <- getURL(paste("http://stats.grok.se/json/en/latest90/", page, sep=""))
data <- fromJSON(raw_data)
views <- data.frame(timestamp=paste(names(data$daily_views), " 12:00:00", sep=""), stringsAsFactors=F)
views$count <- data$daily_views
views$timestamp <- as.POSIXlt(views$timestamp) # Transform to POSIX datetime
views <- views[order(views$timestamp),]


cnt <- ts(views$count, frequency=1)

res2 <- tso(y = cnt, cval = 2.5, 
            types = c("AO", "LS", "TC"), maxit = 1, 
            remove.method = "bottom-up", tsmethod = "arima", 
            args.tsmethod = list(order = c(1,1,1)))
print(res2)

p <- ggplot(views, aes(timestamp, count)) + geom_line() + scale_x_datetime() + xlab("") + ylab("views")

points <-data.frame(x = views[res2$outliers$time, 'timestamp'],
                    y = views[res2$outliers$time, 'count'])

p <- p + geom_point(data = points, mapping=aes(x=x, y=y), 
                    shape=1, size=5, color="red")
p
