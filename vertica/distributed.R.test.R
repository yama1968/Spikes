library(distributedR)
distributedR_start(inst=2)  # start DR
distributedR_status()

B <- darray(dim=c(9,9), blocks=c(3,3), sparse=FALSE) # create a darray
foreach(i, 1:npartitions(B),
        init<-function(b = splits(B,i), index=i) {
          b <- matrix(index, nrow=nrow(b), ncol=ncol(b))
          update(b)
        })  # initialize it

getpartition(B) # collect darray data

distributedR_shutdown() # stop DR
