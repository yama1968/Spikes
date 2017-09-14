
# https://stackoverflow.com/questions/34618521/cant-get-the-followers-for-a-specfic-user-on-twitter

library(twitteR)
library(dplyr)


list.of.list.to.data.frame <- function(l) {
  df <- as.data.frame(unlist(l))
  colnames(df)[[1]] <- "to"
  df <- tibble::rownames_to_column(df, var = "from")
  df[["from"]] <- tools::file_path_sans_ext(df[["from"]])
  df
}

filter.strict.egonet <- function(ego.df, from = "from", to = "to") {
  alters <- unique(ego.df[[from]])
  ego.df %>% filter(to %in% alters)
}

###


egonet <- readRDS( file = "/home/yannick/tmp/follower_graph_tmp.rds")
egonet <- list.of.list.to.data.frame(egonet)
summary(egonet)

egonet %>% group_by(from) %>% summarize(cnt = n()) %>% arrange(desc(cnt))
egonet %>% group_by(to) %>% summarize(cnt = n()) %>% arrange(desc(cnt))


strict <- filter.strict.egonet(egonet)
summary(strict)

egonet %>% filter(to == "bug")

solo <- egonet %>% group_by(to) %>% summarize(cnt = n()) %>% filter(cnt == 1) %>% select(to) %>% unlist %>% unique
egonet2 <- egonet %>% filter(! (to %in% solo))

ig <- igraph::graph.edgelist(egonet2 %>% as.matrix)
plot(ig)
