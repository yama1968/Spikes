
library(dplyr)
library(tidyr)
library(stringr)

data(mtcars)

head(mtcars, 20)

mtcars %>%
    group_by(cyl) %>%
    summarise(disp.avg    = mean(cyl),
              carb.max    = max(carb))

mtcars %>%
    group_by(cyl, carb) %>%
    summarise(cnt   = n()) %>%
    spread(carb, cnt, fill = 0)

mtcars %>%
    mutate(model    = rownames(mtcars),
           brand    = word(model, 1)) %>%
    head(10)

branded <- mtcars %>%
    mutate(brand   = word(rownames(mtcars, 1))) %>%
    group_by(brand) %>%
    arrange(hp, disp) %>%
    mutate(nb      = row_number()) %>%
    ungroup()
branded %>%
    head(10)

branded %>%
    group_by(brand) %>%
    summarise(min.hp    = min(hp),
              max.hp    = max(hp),
              qty       = n())

doubled <- branded %>%
    mutate(previous = nb - 1) %>%
    inner_join(branded %>% 
                 mutate(hp.prev    = hp,
                        nb.prev    = nb) %>%
                 select(hp.prev, nb.prev, brand),
              by = c("brand",
                     "previous" = "nb.prev")) %>%
    select(-previous) %>%
    mutate(hp.incr  = hp - hp.prev,
           gap      = hp.incr > 10)

doubled %>%
    filter(brand %in% c("Hornet", "Merc", "Toyota"))

regrouped <- doubled %>%
    group_by(brand) %>%
    arrange(brand, hp, disp) %>%
    mutate(hp.cum   = cumsum(hp),
           gap.cum  = cumsum(gap))
