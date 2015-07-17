
setwd("/home2/yannick2/github/Spikes/rjags")

N <- 2000
x <- 1:N
epsilon <- rnorm(N, 0, 1)
y <- 2 * x + 1 + epsilon

# 
# write.table(data.frame(X = x, Y = y, Epsilon = epsilon),
#             file = 'example2.data',
#             row.names = FALSE,
#             col.names = TRUE)


library('rjags')

jags <- jags.model('example2.bug',
                   data = list('x' = x,
                               'y' = y,
                               'N' = N),
                   n.chains = 4,
                   n.adapt = 1000)

# system.time( { update(jags, 1000) } )

system.time( { samples <- coda.samples(jags,
                                       c('a', 'b'),
                                       5000)
} )

plot(samples)