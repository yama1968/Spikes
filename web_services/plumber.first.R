# myfile.R

# library(devtools)
# install_github("trestletech/plumber")
library(plumber)

r <- plumb("plumber.myfile.R")  # Where 'myfile.R' is the location of the file shown above
r$run(port=8000)



