#

library(rstan)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

model_string <- "
data {
  # nomber of data points
  int n1;
  int n2;
  # number of successes
  int y1[n1];
  int y2[n2];
}

parameters {
  real<lower=0, upper=1> theta1;
  real<lower=0, upper=1> theta2;
}

model {
  theta1   ~ beta(1, 1);
  theta2   ~ beta(1, 1);
  y1       ~ bernoulli(theta1);
  y2       ~ bernoulli(theta2);
}

generated quantities {

}
"

y1 <- c(0, 1, 0, 0, 0, 0, 1, 0, 0, 0)
y2 <- c(0, 0, 1, 1, 1, 0, 1, 1, 1, 0)
data_list <- list(y1 = y1, y2 = y2, n1 = length(y1), n2 = length(y2))

stan_samples <- stan(model_code = model_string, data = data_list)

stan_samples
plot(stan_samples)

s <- as.data.frame(stan_samples)
print(head(s))

print(mean(s$theta1 < s$theta2))

library(ggplot2)

qplot(s$theta2 - s$theta1, geom = "histogram", bins = 20)

# probability that the difference between the two underlying rates is smaller than 0.2
print(mean(abs(s$theta1 - s$theta2) < 0.2))

sample.cows <- function(sample.A, sample.B) {
  data_list <- list(y1 = sample.A,
                    y2 = sample.B,
                    n1 = length(sample.A),
                    n2 = length(sample.B))
  stan(model_code = model_string,
       data = data_list)
}

# 3- probability that rate of illness with B (i.e. theta2) is higher than with A (i.e. theta1)

print(mean(s$theta1 > s$theta2))

# => A is more effective than B!

# 4- cows and milk

diet_milk <-  c(651, 679, 374, 601, 401, 609, 767, 709, 704, 679)
normal_milk <- c(798, 1139, 529, 609, 553, 743, 151, 544, 488, 555, 257, 692, 678, 675, 538)

# was the diet any good?

milk_string <- "
data {
  # nomber of data points
  int n1;
  int n2;
  # number of successes
  int m1[n1];
  int m2[n2];
}

parameters {
  real<lower=0> mu1;
  real<lower=0> mu2;
  real<lower=0> sigma1;
  real<lower=0> sigma2;
}

model {
  mu1           ~ uniform(0, 2000);
  mu2           ~ uniform(0, 2000);
  sigma1        ~ uniform(0, 2000);
  sigma2        ~ uniform(0, 2000);

  for (i in 1:n1) {
    m1[i]       ~ normal(mu1, sigma1);
  }
  for (i in 1:n2) {
    m2[i]       ~ normal(mu2, sigma2);
  }
}

generated quantities {
}
"

milk_samples <- stan(model_code = milk_string,
                     data       = list(m1 = diet_milk,
                                       m2 = normal_milk,
                                       n1 = length(diet_milk),
                                       n2 = length(normal_milk)),
                     iter       = 10000,
                     thin       = 2,
                     cores      = 4,
                     chains     = 8)
print(milk_samples)
plot(milk_samples)
milk_s <- as.data.frame(milk_samples)

print(mean(milk_s$mu1 > milk_s$mu2))


########################################################################################

mutant_string <- "
data {
  # nomber of data points
  int n1;
  int n2;
  # number of successes
  int m1[n1];
  int m2[n2];
}

parameters {
  real<lower=0> mu1;
  real<lower=0> mu2;
  real<lower=0> sigma1;
  real<lower=0> sigma2;
}

model {
  mu1           ~ uniform(0, 2000);
  mu2           ~ uniform(0, 2000);
  sigma1        ~ uniform(0, 2000);
  sigma2        ~ uniform(0, 2000);

  for (i in 1:n1) {
    m1[i]       ~ student_t(3, mu1, sigma1);
  }
  for (i in 1:n2) {
    m2[i]       ~ student_t(3, mu2, sigma2);
  }
}

generated quantities {
}
"

diet_milk <- c(651, 679, 374, 601, 4000, 401, 609, 767, 3890, 704, 679)
normal_milk <- c(798, 1139, 529, 609, 553, 743, 3,151, 544, 488, 15, 257, 692, 678, 675, 538)

mutant_samples <- stan(model_code = mutant_string,
                     data       = list(m1 = diet_milk,
                                       m2 = normal_milk,
                                       n1 = length(diet_milk),
                                       n2 = length(normal_milk)),
                     iter       = 10000,
                     thin       = 2,
                     cores      = 4,
                     chains     = 8)
print(mutant_samples)
mutant_s <- as.data.frame(mutant_samples)

print(mean(mutant_s$mu1 > mutant_s$mu2))

qplot(mutant_s$mu1 - mutant_s$mu2, geom = "histogram", bins = 20)
