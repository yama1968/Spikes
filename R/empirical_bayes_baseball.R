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
    mutate(eb_estimate = (H + alpha0) / (AB + alpha0 + beta0))

career_eb %>% arrange(eb_estimate)
career_eb %>% arrange(desc(eb_estimate))


library(VGAM)

# negative log likelihood of data given alpha; beta
ll <- function(alpha, beta) {
    -sum(dbetabinom.ab(career$H, career$AB, alpha, beta, log = TRUE))
}

m <- mle(ll, start = list(alpha = 1, beta = 10), method = "L-BFGS-B")
coef(m)
