# http://h2o.ai/blog/2015/12/glrm-transfer-learning/

library(h2o)
h2o.init(nthreads = -1, max_mem_size = "2G")

workdir <- "/tmp"

download.file("https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/census/ACS_13_5YR_DP02_cleaned.zip",
              file.path(workdir, "ACS_13_5YR_DP02_cleaned.zip"), "wget", quiet = TRUE)
acs_orig <- h2o.importFile(path = file.path(workdir, "ACS_13_5YR_DP02_cleaned.zip"), col.types = c("enum", rep("numeric", 149)))
acs_zcta_col <- acs_orig$ZCTA5
acs_full <- acs_orig[,-which(colnames(acs_orig) == "ZCTA5")]

dim(acs_full)
summary(acs_full)

acs_model <- h2o.glrm(training_frame = acs_full, k = 12, 
                      transform = "STANDARDIZE", loss = "Quadratic", 
                      regularization_x = "Quadratic", regularization_y = "L1", 
                      max_iterations = 100, gamma_x = 0.25, gamma_y = 0.5)
plot(acs_model)

zcta_arch_x <- h2o.getFrame(acs_model@model$representation_name)
head(zcta_arch_x)

idx <- ((acs_zcta_col == "10065") |   # Manhattan, NY (Upper East Side)
            (acs_zcta_col == "11219") |   # Manhattan, NY (East Harlem)
            (acs_zcta_col == "66753") |   # McCune, KS
            (acs_zcta_col == "84104") |   # Salt Lake City, UT
            (acs_zcta_col == "94086") |   # Sunnyvale, CA
            (acs_zcta_col == "95014"))    # Cupertino, CA
city_arch <- as.data.frame(zcta_arch_x[idx,1:2])
xeps <- (max(city_arch[,1]) - min(city_arch[,1])) / 10
yeps <- (max(city_arch[,2]) - min(city_arch[,2])) / 10
xlims <- c(min(city_arch[,1]) - xeps, max(city_arch[,1]) + xeps)
ylims <- c(min(city_arch[,2]) - yeps, max(city_arch[,2]) + yeps)
plot(city_arch[,1], city_arch[,2], xlim = xlims, ylim = ylims, xlab = "First Archetype", ylab = "Second Archetype", main = "Archetype Representation of Zip Code Tabulation Areas")
text(city_arch[,1], city_arch[,2],
     labels = c("Upper East Side", "East Harlem", "McCune", "Salt Lake City", "Sunnyvale", "Cupertino"), pos = 1)



###

download.file("https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/census/whd_zcta_cleaned.zip", 
              file.path(workdir, "whd_zcta_cleaned.zip"), "wget", quiet = TRUE)
whd_zcta <- h2o.importFile(path = file.path(workdir, "whd_zcta_cleaned.zip"), col.types = c(rep("enum", 7), rep("numeric", 97)))
dim(whd_zcta)
summary(whd_zcta)

split <- h2o.runif(whd_zcta)
train <- whd_zcta[split <= 0.8,]
test <- whd_zcta[split > 0.8,]

myY <- "flsa_repeat_violator"
myX <- setdiff(5:ncol(train), which(colnames(train) == myY))
orig_time <- system.time(dl_orig <- h2o.deeplearning(x = myX, y = myY, training_frame = train, validation_frame = test, 
                                                     distribution = "multinomial", epochs = 2, hidden = c(50,50,50)))

zcta_arch_x$zcta5_cd <- acs_zcta_col
whd_arch <- h2o.merge(whd_zcta, zcta_arch_x, all.x = TRUE, all.y = FALSE)
whd_arch$zcta5_cd <- NULL
summary(whd_arch)

train_mod <- whd_arch[split <= 0.8,]
test_mod  <- whd_arch[split > 0.8,]
myX <- setdiff(5:ncol(train_mod), which(colnames(train_mod) == myY))
mod_time <- system.time(dl_mod <- h2o.deeplearning(x = myX, y = myY, training_frame = train_mod, validation_frame = test_mod, 
                                                   distribution = "multinomial", epochs = 2, hidden = c(50,50,50)))

colnames(acs_orig)[1] <- "zcta5_cd"
whd_acs <- h2o.merge(whd_zcta, acs_orig, all.x = TRUE, all.y = FALSE)
whd_acs$zcta5_cd <- NULL
summary(whd_acs)

train_comb <- whd_acs[split <= 0.8,]
test_comb <- whd_acs[split > 0.8,]
myX <- setdiff(5:ncol(train_comb), which(colnames(train_comb) == myY))
comb_time <- system.time(dl_comb <- h2o.deeplearning(x = myX, y = myY, training_frame = train_comb, validation_frame = test_comb, 
                                                     distribution = "multinomial", epochs = 2, hidden = c(50,50,50)))

data.frame(original = c(orig_time[3], h2o.logloss(dl_orig, train = TRUE), h2o.logloss(dl_orig, valid = TRUE)),
           reduced  = c(mod_time[3], h2o.logloss(dl_mod, train = TRUE), h2o.logloss(dl_mod, valid = TRUE)),
           combined = c(comb_time[3], h2o.logloss(dl_comb, train = TRUE), h2o.logloss(dl_comb, valid = TRUE)),
           row.names = c("runtime", "train_logloss", "test_logloss"))
#                 original   reduced  combined
# runtime       40.3590000 6.5790000 7.5500000
# train_logloss  0.2467982 0.1895277 0.2440147
# test_logloss   0.2429517 0.1980886 0.2277701

