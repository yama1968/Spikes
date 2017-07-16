
# https://stackoverflow.com/questions/34618521/cant-get-the-followers-for-a-specfic-user-on-twitter

library(twitteR)

consumer_key <- Sys.getenv("tw_CONSUMER_KEY")
consumer_secret <- Sys.getenv("tw_CONSUMER_SECRET")
access_token <- Sys.getenv("tw_ACCESS_TOKEN")
access_secret <- Sys.getenv("tw_ACCESS_SECRET")

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

start <- getUser("yannick_martel")

friends.object <- lookupUsers(start$getFollowerIDs())

length(friends.object)

class(friends.object[[1]])

foo <- friends.object[c(1)]

followers.cache <- list()

getFollowers.with.cache <- function(x) {
  x.id <- x$getScreenName()

  if (is.null(followers.cache[[x.id]])) {
    # mettre la limitation de cadence ici en fait!!!!
    y <- x$getFollowers()
    followers.cache[[x.id]] <<- y
    print("added to "); print(x.id)
    y
  } else
    followers.cache[[x.id]]
}


max <- 15
so.far <- 0
min15 <- 16 * 60

accu <- list()

Sys.sleep(min15)

for (x in friends.object) {
  print(x$getName()); print(x$getScreenName())
  if (!is.null(accu[[x$getScreenName()]])) {
    print("   passed")
  } else {
    f <- getFollowers.with.cache(x)
    f.names <- lapply(X = f, FUN = function(x) x$getScreenName())
    f.names.collapsed <- paste(f.names, collapse = "||")
    print(f.names.collapsed)
    accu[[(x$getScreenName())]] <- f.names

    so.far <- so.far + 1
    if (so.far %% max == 0) {
      saveRDS(accu, file = "/home/yannick/tmp/follower_graph_tmp.rds")
      print(paste(">> waiting for ", min15, " seconds"))
      Sys.sleep(min15)
    }
  }
}

saveRDS(accu, file = "/home/yannick/tmp/follower_graph1.rds")

for (i in names(accu)) if (0 == length(accu[[i]])) { print(i); accu[[i]] <- NULL }
