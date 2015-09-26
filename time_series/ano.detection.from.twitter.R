

install.packages("devtools")
devtools::install_github("twitter/AnomalyDetection")

library(AnomalyDetection)

data(raw_data)
res = AnomalyDetectionTs(raw_data, max_anoms=0.02, direction='both', plot=TRUE)
res$plot


#######################################################

