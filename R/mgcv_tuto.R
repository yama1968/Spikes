
library(mgcv)
data(meuse, package = 'sp')

mod_sep <- gam(copper ~ s(dist, by = landuse) + landuse,
               data = meuse,
               method = "REML")

summary(mod_sep)
plot(mod_fs, pages = 1)
vis.gam(mod_sep, view = c("dist", "landuse"), plot.type = 'persp', theta = 45)

mod_fs <- gam(copper ~ s(dist, landuse, bs = 'fs'),
               data = meuse,
               method = "REML")

summary(mod_sep)
plot(mod_sep, pages = 1)
vis.gam(mod_fs, view = c("dist", "landuse"), plot.type = 'persp', theta = 45)

###

tensor_mod <- gam(cadmium ~ te(x, y, elev),
                  data = meuse,
                  method = 'REML')
summary(tensor_mod)
coef(tensor_mod)
plot(tensor_mod, pages = 1)

tensor_mod2 <- gam(cadmium ~ s(x, y) + s(elev) + ti(x, y, elev),
                  data = meuse,
                  method = 'REML')
summary(tensor_mod2)
coef(tensor_mod2)
plot(tensor_mod2, pages = 1)

#### classifying purchasing behavior

library(mgcv)

# Plot with the intercept
plot(log_mod2, pages = 1, trans = plogis,
     shift = coef(log_mod2)[1],
     setWithMean = T)
