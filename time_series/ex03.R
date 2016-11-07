
# 3.2.2

library(reshape)
library(ggplot2)

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/ApprovActiv.dat"
www <- "https://github.com/burakbayramli/kod/raw/master/books/Introductory_Time_Series_with_R_Metcalfe/ApprovActiv.dat"
Build.dat <- read.table(www, header=T)
attach(Build.dat)
App.ts <-ts(Approvals, start=c(1996,1), freq=4)
Act.ts <-ts(Activity, start=c(1996,1), freq=4)
ts.plot(App.ts, Act.ts, lty=c(1,3))

acf(ts.union(App.ts, Act.ts))

plot(decompose(App.ts))
plot(decompose(Act.ts))

app.ran <- decompose(App.ts)$random
app.ran.ts <- window(app.ran, start=c(1996,3), end=c(2005,4))
act.ran <- decompose(Act.ts)$random
act.ran.ts <- window(act.ran, start=c(1996,3), end=c(2005,4))

ts.plot(app.ran, act.ran, lty=c(1,3))
a <- acf(ts.union(app.ran.ts, act.ran.ts))
print(a)
c <- ccf(app.ran.ts, act.ran.ts)
print(c)




####

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/motororg.dat"
Motor.dat <- read.table(www, header=T)
attach(Motor.dat)
Comp.ts <- ts(complaints, start=c(1996,1), freq=12)
plot(Comp.ts, xlab="Time / months", ylab="Complaints")

Comp.hw1 <- HoltWinters(complaints, beta=FALSE, gamma=FALSE)
Comp.hw1
plot(Comp.hw1)
Comp.hw1$SSE

Comp.hw2 <- HoltWinters(complaints, alpha=0.2, beta=FALSE, gamma=FALSE)
Comp.hw2
plot(Comp.hw2)
Comp.hw2$SSE

###

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/wine.dat"
wine.dat <- read.table(www, header=T)
attach(wine.dat)
sweetw.ts <- ts(sweetw, start=c(1980,1), freq=12)
plot(sweetw.ts, xlab= "Time (months)", ylab = "sales (1000 litres)")

res.sweetw <- breakout(sweetw, 
                     min.size = 10, method="multi", beta=0.001, degree=1,
                     plot=TRUE)
res.sweetw$plot

sweetw.hw <- HoltWinters(sweetw.ts, seasonal="mult")
sweetw.hw; sweetw.hw$coef; print(sqrt(sweetw.hw$SSE/length(sweetw)))
sd(sweetw)

plot(sweetw.hw$fitted)

df <- data.frame(sweetw.hw$fitted)
df["time"] <- 1:nrow(df)

print (sd(df$xhat))
print (sd(df$level))
print (sd(df$season))

df <- melt(df, id.vars="time", variable_name="series")

ggplot(df, aes(time,value)) + geom_line(aes(colour = series))
ggplot(df, aes(time,value)) + geom_line() + facet_grid(series ~ .)

####


data("AirPassengers")

AP <- AirPassengers
plot(AP)
AP.decom <- decompose(AP, "multiplicative")
plot(AP.decom)
acf(AP.decom$random[7:138])

sd(AP[7:138])
sd(AP[7:138] - AP.decom$trend[7:138])
sd(AP.decom$random[7:138])

AP.hw <- HoltWinters(AP, seasonal="mult")
plot(AP.hw)
print(AP.hw)
plot(AP.hw$fitted)

AP.predict <- predict(AP.hw, n.ahead=4*12)
ts.plot(AP, AP.predict, lty=1:2)

library(BreakoutDetection)

AP.res = breakout(AP[1:length(AP)], 
                  min.size=24, method='multi', beta=.001, degree=1, plot=TRUE)
AP.res$plot




