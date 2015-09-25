

N <- 2000
x <- 1:N
epsilon <- rnorm(N, 0, 10)
y <- 2 * x + 1 + epsilon


library('rjags')

chains = 4

x_init = lapply(1:chains, function (i) { list(a = i/10, b = i/10) })


m <- jags.parallel (model.file = 'example2.bug',
                    data = list('x' = x,
                                "y" = y,
                                'N' = N),
                    n.chains = chains,
                    inits = x_init,
                    n.iter = 100000,
                    parameters.to.save = c("a", "b") )

print(m)
