library('R2jags')

chains <- 4
nodes <- 4

data = list( 
            y = c(100.8, 81.6, 66.5, 34.8, 30.6, 7, 19.8, 92.5,
                  154.4, 125.9, 84.8, 68.1, 38.5, 22.8, 10.2, 24.1, 82.9,
                  132, 130.9, 118.1, 89.9, 66.6, 60, 46.9, 41, 21.3, 16,
                  6.4, 4.1, 6.8, 14.5, 34, 45, 43.1, 47.5, 42.2, 28.1, 10.1,
                  8.1, 2.5, 0, 1.4, 5, 12.2, 13.9, 35.4, 45.8, 41.1, 30.4,
                  23.9, 15.7, 6.6, 4, 1.8, 8.5, 16.6, 36.3, 49.7, 62.5, 67,
                  71, 47.8, 27.5, 8.5, 13.2, 56.9, 121.5, 138.3, 103.2,
                  85.8, 63.2, 36.8, 24.2, 10.7, 15, 40.1, 61.5, 98.5, 124.3,
                  95.9, 66.5, 64.5, 54.2, 39, 20.6, 6.7, 4.3, 22.8, 54.8,
                  93.8, 95.7, 77.2, 59.1, 44, 47, 30.5, 16.3, 7.3, 37.3,
                  73.9))

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


