
N <- 1000
x <- 1:N
epsilon <- rnorm(N, 0, 1)
y <- x + epsilon

write.table(data.frame(X = x, Y = y, Epsilon = epsilon),
            file = 'example2.data',
            row.names = FALSE,
            col.names = TRUE)


library('rjags')

jags <- jags.model('example2.bug',
                   data = list('x' = x,
                               'y' = y,
                               'N' = N),
                   n.chains = 4,
                   n.adapt = 100)

update(jags, 1000)

jags.samples(jags,
             c('a', 'b'),
             1000)

