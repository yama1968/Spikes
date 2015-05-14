# Appendix Cox-Regression, to an R companion to logistic regression


library(survival)
library(car)
args(coxph)

url <- "http://socserv.mcmaster.ca/jfox/Books/Companion/data/Rossi.txt"
Rossi <- read.table(url, header=TRUE)
Rossi[1:5, 1:10]

mod.allison <- coxph(Surv(week, arrest) ~
                       fin + age + race + wexp + mar + paro + prio,
                       data=Rossi)
mod.allison
summary(mod.allison)


plot(survfit(mod.allison), ylim=c(0.7, 1), xlab="Weeks",
     ylab="Proportion Not Rearrested")


Rossi.fin <- with(Rossi, data.frame(fin=c(0, 1),
                                    age=rep(mean(age), 2), race=rep(mean(race == "other"), 2),
                                    wexp=rep(mean(wexp == "yes"), 2), mar=rep(mean(mar == "not married"), 2),
                                    paro=rep(mean(paro == "yes"), 2), prio=rep(mean(prio), 2)))
plot(survfit(mod.allison, newdata=Rossi.fin), conf.int=TRUE,
     lty=c(1, 2), ylim=c(0.6, 1), xlab="Weeks",
     ylab="Proportion Not Rearrested")
legend("bottomleft", legend=c("fin = no", "fin = yes"), lty=c(1 ,2), inset=0.02)


Rossi.2 <- unfold(Rossi, time="week",
                  event="arrest", cov=11:62, cov.names="employed")

mod.allison.2 <- coxph(Surv(start, stop, arrest.time) ~
                         fin + age + race + wexp + mar + paro + prio + employed,
                       data=Rossi.2)
summary(mod.allison.2)


Rossi.3 <- unfold(Rossi, "week", "arrest", 11:62, "employed", lag=1)
mod.allison.3 <- coxph(Surv(start, stop, arrest.time) ~
                         fin + age + race + wexp + mar + paro + prio + employed,
                       data=Rossi.3)
summary(mod.allison.3)

mod.allison.4 <- coxph(Surv(week, arrest) ~ fin + age + prio,
                       data = Rossi)
summary(mod.allison.4)

czph <- cox.zph(mod.allison.4)
czph
par(mfrow=c(2, 2))
plot(czph)
par(mfrow=c(1,1))

mod.allison.5 <- coxph(Surv(start, stop, arrest.time) ~
                         fin + age + age:stop + prio,
                       data=Rossi.2)
mod.allison.5

Rossi$age.cat <- recode(Rossi$age, " lo:19=1; 20:25=2; 26:30=3; 31:hi=4 ")
xtabs(~ age.cat, data=Rossi)

mod.allison.6 <- coxph(Surv(week, arrest) ~
                         fin + prio + strata(age.cat), data=Rossi)
mod.allison.6





