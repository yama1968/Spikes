
library(dplyr)
library(tidyr)
library(Lahman)

career <- Batting %>%
  filter(AB > 0) %>%
  anti_join(Pitching, by = "playerID") %>%
  group_by(playerID) %>%
  summarize(H = sum(H), AB = sum(AB), average = H / AB)

career <- Master %>%
  tbl_df() %>%
  dplyr::select(playerID, nameFirst, nameLast) %>%
  unite(name, nameFirst, nameLast, sep = " ") %>%
  inner_join(career, by = "playerID") %>%
  dplyr::select(-playerID)

career

career_filtered <- career %>%
  filter(AB >= 400)

m <- MASS::fitdistr(career_filtered$average,
                    dbeta,
                    start = list(shape1 = 1, shape2 = 10))

m

alpha0 <- m$estimate[1]
beta0 <- m$estimate[2]
