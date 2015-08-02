require(rjags)

# Generate random data from known parameter values:
set.seed(47405)
trueM1 = 100
N1 = 200
trueM2 = 145 # 145 for first example below; 130 for second example
N2 = 200
trueSD = 15
effsz = abs( trueM2 - trueM1 ) / trueSD
y1 = rnorm( N1 )
y1 = (y1-mean(y1))/sd(y1) * trueSD + trueM1
y2 = rnorm( N2 )
y2 = (y2-mean(y2))/sd(y2) * trueSD + trueM2
y = c( y1 , y2 )
N = length(y)

# Must have at least one data point with fixed assignment 
# to each cluster, otherwise some clusters will end up empty:
Nclust = 2
clust = rep(NA,N) 
clust[which.min(y)] = 1 # smallest value assigned to cluster 1
clust[which.max(y)] = 2 # highest value assigned to cluster 2 

hist(y)

modelstring <-"
model {
    # Likelihood:
    for( i in 1 : N ) {
      y[i] ~ dnorm( muOfClust[clust[i]] , tau )
      clust[i] ~ dcat( pClust[1:Nclust] )
    }
    # Prior:
    tau ~ dgamma( 0.01 , 0.01 )
    sigma <- sqrt(1/tau)
    for ( clustIdx in 1: Nclust ) {
      muOfClust[clustIdx] ~ dnorm( 0 , 1.0E-10 )
    }
    pClust[1:Nclust] ~ ddirch( onesRepNclust )
}

"
m <- NA

m <- jags.model(textConnection(modelstring),
                data = list(
                        y = y ,
                        N = N ,
                        Nclust = Nclust ,
                        clust = clust ,
                        onesRepNclust = rep(1,Nclust)
                ),
                n.chains = 4,
                n.adapt = 1000)

s <- coda.samples(model = m,
                  c('muOfClust', 'sigma'),
                  10000)

summary(s)
