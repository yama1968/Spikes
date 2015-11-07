

df1 <- read.table(textConnection(" Item1 Item2 Item3 
    22    52    16 
    42    33    24 
    44     8    19 
    52    47    18 
    45    43    34 
    37    32    39 "), header = T)
df1
r <- c(t(as.matrix(df1)))
f = c("Item1", "Item2", "Item3")   # treatment levels 
k = 3                    # number of treatment levels 
n = 6                    # observations per treatment 
tm = gl(k, 1, n*k, factor(f))   # matching treatments 

av = aov(r ~ tm) 
summary(av)

##############################"

library(MASS)
tbl <- table(survey$Smoke, survey$Exer)
chisq.test(tbl)

head(survey)
chisq.test(table(survey$W.Hnd, survey$Sex))
