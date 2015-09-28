library('R2jags')

chains <- 4
nodes <- 4

page <- "FR"
raw_data <- getURL(paste("http://stats.grok.se/json/en/latest90/", page, sep=""))
data <- fromJSON(raw_data)
views <- data.frame(timestamp=paste(names(data$daily_views), " 12:00:00", sep=""), stringsAsFactors=F)
views$count <- data$daily_views
views$timestamp <- as.POSIXlt(views$timestamp) # Transform to POSIX datetime
views <- views[order(views$timestamp),]

data = list(n = length(views$count), 
            y = views$count)

system.time (m <- jags.parallel(
    model.file = 'arma2.2.jags',
    data = data,
    n.chains = chains,
    n.cluster = nodes,
    n.burnin = 4000,
    n.thin = 4,
    parameters.to.save = c('deviance', 'delta', 'theta', 'c', 'sigma', 'phi', 'm'),
    jags.module = c("dic"),
    n.iter = 20000,
    DIC = TRUE
))

print (m)

m.means <- m$BUGSoutput$mean$m
m.sd <- m$BUGSoutput$sd$m
print(mean(m.sd))

ts.plot(ts(data$y), ts(m.means+2*m.sd), ts(m.means-2*m.sd), lty=c(1,3,3))

delta.mean <- m$BUGSoutput$mean$delta
print(delta.mean)
# 14.99
