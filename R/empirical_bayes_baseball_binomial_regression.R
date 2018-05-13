##

# http://varianceexplained.org/r/empirical_bayes_baseball/

library(dplyr)
library(tidyr)
library(Lahman)

career <- Batting %>%
  filter(AB > 0) %>%
  anti_join(Pitching, by = "playerID") %>%
  group_by(playerID) %>%
  summarize(H = sum(H), AB = sum(AB)) %>%
  mutate(average = H / AB)

# use names along with the player IDs
career <- Master %>%
  tbl_df() %>%
  select(playerID, nameFirst, nameLast) %>%
  unite(name, nameFirst, nameLast, sep = " ") %>%
  inner_join(career, by = "playerID") %>%
  select(-playerID)

# just like the graph, we have to filter for the players we actually
# have a decent estimate of
career_filtered <- career %>%
  filter(AB >= 500)

m <- MASS::fitdistr(career_filtered$average, dbeta,
                    start = list(shape1 = 1, shape2 = 10))
m

alpha0 <- m$estimate[1]
beta0 <- m$estimate[2]

career_eb <- career %>%
  mutate(eb_estimate = (H + alpha0) / (AB + alpha0 + beta0)) %>%
  mutate(alpha1 = H + alpha0,
         beta1 = AB - H + beta0) %>%
  arrange(desc(eb_estimate))


career_eb %>% arrange(eb_estimate)
career_eb %>% arrange(desc(eb_estimate))


library(VGAM)

# negative log likelihood of data given alpha; beta
ll <- function(alpha, beta) {
  -sum(dbetabinom.ab(career$H, career$AB, alpha, beta, log = TRUE))
}

m <- mle(ll, start = list(alpha = 1, beta = 10), method = "L-BFGS-B")
coef(m)

## http://varianceexplained.org/r/bayesian_fdr_baseball/

career_eb <- career_eb %>%
  mutate(PEP = pbeta(.3, alpha1, beta1)) %>%
  arrange(PEP) %>%
  mutate(qvalue = cummean(PEP))

## http://varianceexplained.org/r/beta_binomial_baseball/

library(ggplot2)

career %>%
  filter(AB >= 20) %>%
  ggplot(aes(AB, average)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_log10()


library(gamlss)
library(broom)

fit <- gamlss(cbind(H, AB - H) ~ log(AB),
              data = career_eb,
              family = BB(mu.link = "identity"))

td <- tidy(fit)
td

mu <- fitted(fit, parameter = "mu")
sigma <- fitted(fit, parameter = "sigma")

head(mu)

career_eb_wAB <- career_eb %>%
  dplyr::select(name, H, AB, original_eb = eb_estimate) %>%
  mutate(mu = mu,
         alpha0 = mu / sigma,
         beta0 = (1 - mu) / sigma,
         alpha1 = alpha0 + H,
         beta1 = beta0 + AB - H,
         new_eb = alpha1 / (alpha1 + beta1))

qplot(data = career_eb_wAB, original_eb, new_eb, alpha = I(0.1), color = log10(AB))
qplot(data = career_eb_wAB, AB, original_eb - new_eb, alpha = I(0.03), log = "x")
