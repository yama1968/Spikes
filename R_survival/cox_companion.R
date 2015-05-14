# Appendix Cox-Regression, to an R companion to logistic regression


library(survival)
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


