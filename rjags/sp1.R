
N <- 1000
x <- rnorm(N, 0, 5)

write.table(x,
            file = 'example1.data',
            row.names = FALSE,
            col.names = FALSE)

library('rjags')

jags <- jags.model('example1.bug',
                   data = list('x' = x,
                               'N' = N),
                   n.chains = 4,
                   n.adapt = 100)

update(jags, 1000)

jags.samples(jags,
             c('mu', 'tau'),
             1000)


