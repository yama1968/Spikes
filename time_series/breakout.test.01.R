
library(BreakoutDetection)

data(Scribe)
res = breakout(Scribe, min.size=24, method='multi', beta=.001, degree=1, plot=TRUE)
res$plot

###


library(tsoutliers)
library(ggplot2)

data(Nile)
nile.list <- Nile[1:length(Nile)]

res.Nile <- breakout(nile.list, 
                     min.size = 10, method="multi", beta=0.001, degree=1,
                     plot=TRUE)
res.Nile$plot

###

library(RJSONIO)
library(RCurl)
library(ggplot2)

page <- "US"
raw_data <- getURL(paste("http://stats.grok.se/json/en/latest90/", page, sep=""))
data <- fromJSON(raw_data)
views <- data.frame(timestamp=paste(names(data$daily_views), " 12:00:00", sep=""), stringsAsFactors=F)
views$count <- data$daily_views
views$timestamp <- as.POSIXlt(views$timestamp) # Transform to POSIX datetime
views <- views[order(views$timestamp),]

res.views <- breakout(views$count,
                      min.size=5, method="multi", beta=0.001, degree=1,
                      plot=TRUE)
res.views$plot


