require(rjags)

data1 <- list(n=c(4,4),
             y=c(3,1))

data <- list(n = c(1000, 1000),  # nb of tests per category
             y = c(   8,    5))  # nb of positives per category

modelstring <-"
model {
        for (i in 1:2) {
                y[i] ~ dbin(p[i], n[i])
                p[i] ~ dunif(0,1)
        }
        more <- step(p[1]-p[2])
        for (i in 1:5) {
                more_half[i] <- step((p[1]-p[2])/p[2]-0.2*i)
        }
}
"

m <- jags.model(textConnection(modelstring),
                data = data,
                n.chains = 4,
                n.adapt = 1000)

s <- coda.samples(model = m,
                  c('p', 'more', 'more_half'),
                  10000)

summary(s)
