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
  mutate(PEP = pbeta(.3, alpha1, beta1))

qplot(career_eb$PEP, geom = "histogram", bins = 100)

qplot(data = career_eb, eb_estimate, PEP, color = log10(AB), alpha = 0.1)

top_players <- career_eb %>%
  arrange(PEP) %>%
  head(100)

mean(top_players$PEP)

career_eb <- career_eb %>%
  arrange(PEP) %>%
  mutate(qvalue = cummean(PEP))

career_eb %>%
  filter(qvalue < 0.01)

## from http://varianceexplained.org/r/bayesian_ab_baseball/

# while we're at it, save them as separate objects too for later:
aaron <- career_eb %>% filter(name == "Hank Aaron")
piazza <- career_eb %>% filter(name == "Mike Piazza")
two_players <- bind_rows(aaron, piazza)

two_players

hideki <- career_eb %>% filter(name == "Hideki Matsui")

three_players <- bind_rows(two_players, hideki)

# let's graph them

library(broom)
library(ggplot2)
theme_set(theme_bw())

three_players %>%
  inflate(x = seq(.28, .33, .00025)) %>%
  mutate(density = dbeta(x, alpha1, beta1)) %>%
  ggplot(aes(x, density, color = name)) +
  geom_line() +
  labs(x = "Batting average", color = "")

# closed form solution

h <- function(alpha_a, beta_a,
              alpha_b, beta_b) {
  j <- seq.int(0, round(alpha_b) - 1)
  log_vals <- (lbeta(alpha_a + j, beta_a + beta_b) - log(beta_b + j) -
                 lbeta(1 + j, beta_b) - lbeta(alpha_a, beta_a))
  1 - sum(exp(log_vals))
}

h(piazza$alpha1, piazza$beta1,
  aaron$alpha1, aaron$beta1)

# confidence and credible intervals

prop.test(two_players$H, two_players$AB)

# Bayesian credible interval playing

credible_interval_approx <- function(a, b, c, d) {
  u1 <- a / (a + b)
  u2 <- c / (c + d)
  var1 <- a * b / ((a + b) ^ 2 * (a + b + 1))
  var2 <- c * d / ((c + d) ^ 2 * (c + d + 1))

  mu_diff <- u2 - u1
  sd_diff <- sqrt(var1 + var2)

  data_frame(posterior = pnorm(0, mu_diff, sd_diff),
             estimate = mu_diff,
             conf.low = qnorm(.025, mu_diff, sd_diff),
             conf.high = qnorm(.975, mu_diff, sd_diff))
}

credible_interval_approx(piazza$alpha1, piazza$beta1, aaron$alpha1, aaron$beta1)

credible <-   credible_interval_approx(piazza$alpha1, piazza$beta1,
                                       career_eb$alpha1, career_eb$beta1)

career_eb_vs_piazza <-
  dplyr::bind_cols(career_eb, credible) %>%
  select(name, posterior, conf.low, conf.high, H, AB) %>%
  arrange(desc(conf.low)) %>%
  mutate(rank.low = 1:nrow(career_eb)) %>%
  arrange(desc(conf.high)) %>%
  mutate(rank.high = 1:nrow(career_eb))


career_eb_vs_piazza

career_eb_vs_piazza %>%
  filter(abs(rank.low - rank.high) > 100)


career_eb_vs_piazza %>%
  filter(conf.low > 0) %>%
  arrange(desc(conf.high - conf.low))


# Bayesian FDR control

career_eb_vs_piazza <- career_eb_vs_piazza  %>%
  arrange(posterior) %>%
  mutate(qvalue = cummean(posterior))

better <- career_eb_vs_piazza %>%
  filter(qvalue < .05)

better

