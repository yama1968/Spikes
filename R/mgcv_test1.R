##

x <- seq(0, pi * 2, 0.1)
sin_x <- sin(x)
y <- sin_x + rnorm(n = length(x), mean = 0, sd = sd(sin_x / 2))
Sample_data <- data.frame(y,x)

library(ggplot2)
ggplot(Sample_data, aes(x, y)) + geom_point()

lm_y <- lm(y ~ x, data = Sample_data)

ggplot(Sample_data, aes(x, y)) + geom_point() + geom_smooth(method = lm)

plot(lm_y, which = 1)

library(mgcv)

gam_y <- gam(y ~ s(x), method = "REML")

x_new <- seq(0, max(x), length.out = 100)
y_pred <- predict(gam_y, data.frame(x = x_new))

ggplot(Sample_data, aes(x, y)) + geom_point() + geom_smooth(method = "gam", formula = y ~s(x))

u <- par(mfrow = c(2,2))
gam.check(gam_y)

par(u)
plot(gam_y)

###

CO2 <- read.csv("../dataset/manua_loa_co2.csv")

CO2$time <- as.integer(as.Date(CO2$Date, format = "%d/%m/%Y"))
CO2_dat <- CO2
CO2 <- CO2[CO2$year %in% (2000:2010),]

ggplot(CO2_dat, aes(time, co2)) + geom_line()

CO2_time <- gam(co2 ~ s(time), data = CO2, method = "REML")
plot(CO2_time)
summary(CO2_time)

CO2_season_time <- gam(co2 ~ s(month, bs = 'cc', k = 12) + s(time), data = CO2, method = "REML")
plot(CO2_season_time)

u <- par(mfrow = c(1,2))
plot(CO2_season_time)
par(u)

u <- par(mfrow = c(2,2))
gam.check(CO2_season_time)
par(u)

CO2_season_time <- gam(co2 ~ s(month, bs = 'cc', k = 12) + s(time), data = CO2_dat, method = "REML")
u <- par(mfrow = c(1,2))
plot(CO2_season_time)
par(u)
