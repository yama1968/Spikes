#

library("pre")
library(dplyr)
library(mgcv)

airq <- airquality[complete.cases(airquality), ]
set.seed(42)
airq.ens <- pre(Ozone ~ ., data = airq)

show(airq.ens)

coefs <- coef(airq.ens) %>% filter(coefficient != 0)
coefs

imps <- importance(airq.ens, round = 4)

set.seed(42)
airq.gpe <- gpe(Ozone ~ ., data = airquality[complete.cases(airquality),],
                base_learners = list(gpe_trees(), gpe_linear(), gpe_earth()))
airq.gpe






m_gam <- gam(Ozone ~ s(Solar.R) + s(Wind) + s(Temp) + Month + Day,
             data = airq,
             select = T,
             method = 'REML')
summary(m_gam)

m_gam <- gam(Ozone ~ s(Solar.R) + s(Wind) + s(Temp) + Month + Day +
               te(Wind, Temp),
             data = airq,
             select = T,
             method = 'REML')
summary(m_gam)

u <- par(mfrow = c(2,2))
plot(m_gam)
par(mfrow = u)
