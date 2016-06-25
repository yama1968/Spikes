#

for (lambda in c(1, 10, 100)) {
  
  print("lambda = ")
  print(lambda)
  
  for (i in 1:10) {
    
    cmds = rpois(10, lambda)
    
    print(c(mean(cmds), sd(cmds), median(cmds)))
  }
}

ppois(120, 100)

plot(dpois(0:100, 30), type="o")
plot(dpois(0:10, 2), type="o")
plot(dpois(0:10, 0.5), type='o')
