
library(twitteR)

consumer_key <- Sys.getenv("tw_CONSUMER_KEY")
consumer_secret <- Sys.getenv("tw_CONSUMER_SECRET")
access_token <- Sys.getenv("tw_ACCESS_TOKEN")
access_secret <- Sys.getenv("tw_ACCESS_SECRET")

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tweets <- searchTwitter('#rstats', n = 50)
tweets

crantastic <- getUser('yannick_martel')
crantastic$getDescription()
crantastic$getFollowersCount()
friends <- crantastic$getFollowers()

library(data.table)
library(dplyr)
library(purrr)

friends_df <- tbl_df(map_df(friends, as.data.frame))

friends_df %>% names

library(ggplot2)

qplot(friends_df$friendsCount, log = "xy", geom = "histogram")
summary(friends_df)

dump_egonet <- function(user_name) {
  user <- getUser(user_name)
  friends <- user$getFollowers()

  friends_name <- sapply(friends, function(x) x$screenName)

  lapply(friends,
         function(friend) {
           print(friend$name)
           his_friends <- friend$getFollowers()
           intersect(friends_name, sapply(his_friends, function(x) x$screenName))
         })
}

ego <- dump_egonet("yannick_martel")
