
# 3.2.2

www <- "http://staff.elena.aut.ac.nz/Paul-Cowpertwait/ts/ApprovActiv.dat"
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



