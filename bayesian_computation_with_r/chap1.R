# Chapter 1

setwd("/home2/yannick2/github/Spikes/bayesian_computation_with_r")

studentdata = read.table("studentdata.txt", sep="\t", header=TRUE)

attach(studentdata)
barplot(table(Drink), xlab="Drink", ylab="Count")

hours.of.sleep = WakeUp - ToSleep
summary(hours.of.sleep)

hist(hours.of.sleep, main="")
boxplot(hours.of.sleep~Gender, ylab="Hours of sleep")

female.haircut = Haircut[Gender == "female"]
male.haircut = Haircut[Gender == "make"]
boxplot(Haircut~Gender)

plot(jitter(ToSleep), jitter(hours.of.sleep))
fit = lm(hours.of.sleep~ToSleep)
summary(fit)
abline(fit)

fit3 = lm(hours.of.sleep~Gender+ToSleep+Job, data=studentdata)
summary(fit3)

require(ggplot2)

ggplot(data=studentdata, aes(x=Dvds)) + geom_histogram() + scale_y_log10() + scale_x_log10()
table(Dvds)
str(Dvds)


# Chap 2

p = seq(0.05, 0.95, by = 0.1)
prior = c(1, 5.2, 8, 7.2, 4.6, 2.1, 0.7, 0.1, 0, 0)
prior = prior / sum(prior)
qplot(prior, type="h", binwidth=0.01)
plot(p, prior, type="h")

require(LearnBayes)
data=c(11,16)
post = pdisc(p, prior, data)
plot(p, post, type="h")

quantile2 = list(p=0.9, x=0.5)
quantile1 = list(p=0.5, x=0.3)
beta.select(quantile1, quantile2)


data("footballscores")
attach(footballscores)
d = favorite - underdog - spread
n = length(d)
v = sum(d^2)
