library(caret)
library(doParallel) # parallel processing
library(dplyr) # Used by caret
library(pROC) # plot the ROC curve

### Use the segmentationData from caret
# Load the data and construct indices to divided it into training and test data sets.
set.seed(10)
data(segmentationData) # Load the segmentation data set
dim(segmentationData)
head(segmentationData,2)
#
trainIndex <- createDataPartition(segmentationData$Case,p=.5,list=FALSE)
trainData <- segmentationData[trainIndex,-c(1,2)]
testData <- segmentationData[-trainIndex,-c(1,2)]
#
trainX <-trainData[,-1] # Create training feature data frame
testX <- testData[,-1] # Create test feature data frame 
y=trainData$Class # Target variable for training

#####


registerDoParallel(4) # Registrer a parallel backend for train
getDoParWorkers() # check that there are 4 workers

ga_ctrl <- gafsControl(functions = rfGA, # Assess fitness with RF
                       method = "cv",    # 10 fold cross validation
                       number = 5,
                       genParallel=TRUE, # Use parallel programming
                       allowParallel = TRUE)
## 
set.seed(10)
lev <- c("PS","WS")     # Set the levels

system.time(rf_ga3 <- gafs(x = trainX, y = y,
                           iters = 10, # 100 generations of algorithm
                           popSize = 20, # population size for each generation
                           levels = lev,
                           gafsControl = ga_ctrl))



plot(rf_ga3) # Plot mean fitness (AUC) by generation
