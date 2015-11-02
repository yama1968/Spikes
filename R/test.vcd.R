
library(vcd)

data("HairEyeColor")

HEC <- structable(Eye ~ Sex + Hair, data = HairEyeColor)
HEC

mosaic(HEC)

doubledecker(HEC)
assoc(HEC)
cotabplot(~Eye + Sex | Hair, data = HEC)
cotabplot(~Eye + Hair | Sex, data = HEC)


##

STD <- structable(~Sex + Class + Age, data = Titanic[, , 2:1, ])
cotabplot(~Class + Age | Sex, data = STD, split_verical = T)

# 
data("Arthritis")

foo <- Arthritis
foo$old <- foo$Age > 40
foo$Age <- NULL
Art <- structable(Improved ~ Treatment + Sex + old, 
                  data = foo)
cotabplot(Improved ~Treatment + old | Sex, data = Art)


library(vcd)
data("Arthritis")
Arthritis$CatAge <- as.factor(20 * (Arthritis$Age %/% 20))
Arthritis$Target <- Arthritis$Improved != "None"

cotabplot(~ Sex + Treatment + CatAge | Target, data = Arthritis)

cotabplot(~ Treatment + CatAge + Improved | Sex, data = Arthritis)

cotabplot(~ Treatment + CatAge + Improved | Sex, data = Arthritis,
          gp = shading_hsv,
          gp_args = list(interpolate = 1:8))



independence_table(Art)
