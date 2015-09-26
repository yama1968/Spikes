
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

