
#Randomly shuffle the data
yourData<-yourData[sample(nrow(yourData)),]

#Create 10 equally size folds
folds <- cut(seq(1,nrow(yourData)),breaks=10,labels=FALSE)

#Perform 10 fold cross validation
for(i in 1:10){
  #Segement your data by fold using the which() function
  testIndexes <- which(folds==i,arr.ind=TRUE)
  testData <- yourData[testIndexes, ]
  trainData <- yourData[-testIndexes, ]
  #Use the test and train data partitions however you desire...
}

