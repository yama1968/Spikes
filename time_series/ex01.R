
data("AirPassengers")

AP <- AirPassengers
plot(AP)
AP.decom <- decompose(AP, "multiplicative")
plot(ts(AP.decom$random[7:138]))
acf(AP.decom$random[7:138])

sd(AP[7:138])
sd(AP[7:138] - AP.decom$trend[7:138])
sd(AP.decom$random[7:138])

#####################################

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/Fontdsdt.dat"
f <- read.table(www, header=T)
plot(ts(f$adflow), ylab="adflow")
acf(f$adflow, xlab='lag (months)', main="")


########################################


doit <- function (myts, nm="") {
    plot(myts, main=nm)
    plot(acf(myts), main=paste("acf", nm))
    plot(myts[1:(length(myts)-1)], myts[2:length(myts)],
         main = paste("lag 1", nm))
    abline(h=0, v=0)
}

shiraz <- ts(c(39,35,16,18,7,22,13,18,20,9,-12,-11,-19,-9,-2,16))
cagey <- ts(c(47,-26,42,-10,27,-8,16,6,-1,25,11,1,25,7,-5,3))

doit(shiraz, "shiraz")
doit(cagey, "cagey")

#################################################

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/global.dat"

g <- read.table(www, header=T)
x <- ts(g$X.0.384)
print(frequency(x))
plot(x)
plot(acf(x))


