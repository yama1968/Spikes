

require(randomForestSRC)
data("pbc")
pbc.f = as.formula("Surv(days,status)~.")
pbc.out = rfsrc(pbc.f, pbc, ntree = 1000,
                splitrule = "logrankscore", forest = T)
plot(pbc.out)

pbc2.out = rfsrc(Surv(days,status)~.-ascites-treatment-spiders-edema-sex, 
                 pbc, ntree = 1000,
                 splitrule = "logrankscore", forest = T)

# incremental effects

ntree=3000
imp = pbc.out$importance
pnames = pbc.out$xvar.names
pnames.order = pnames[rev(order(imp))]
n.pred = length(pnames.order)
pbc.err = rep(0, n.pred)

for (k in 1:n.pred){
        rsf.f = "Surv(days,status)~"
        rsf.f = as.formula(paste(rsf.f,
                                 paste(pnames.order[1:k], collapse="+")))
        pbc.err[k] = rfsrc(rsf.f, pbc, ntree = ntree,
                           splitrule = "logrankscore")$err.rate[ntree]
}

pbc3.imp.out = as.data.frame(
        cbind(round(rev(sort(imp)),4),
              round(pbc.err,4),
              round(-diff(c(0.5,pbc.err)),4)),
        row.names = pnames.order)
colnames(pbc3.imp.out) = c("Imp", "Err", "Drop Err")
print(pbc3.imp.out)

