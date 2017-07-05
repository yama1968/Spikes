
library(tidyjson)
library(dplyr)
library(jsonlite)
library(data.table)

egonet <- read_json("c:/home/Datasets/result_ymartel/egonet1.json")
str(egonet)

length(egonet$nodes)

nodes <- do.call(rbind.data.frame, egonet$nodes) %>% as.data.table
               
nodes %>%
  filter(name == "Yannick Martel")

yannick <- "162136490"

edges <- do.call(rbind.data.frame, egonet$links) %>% as.data.table

edges2 <- edges %>%
  filter(source != yannick & target != 162136490)

egonet2 <- list(
  nodes = nodes %>% as.data.frame,
  links = edges2 %>% as.data.frame
)

write_json(x = egonet2, path = "c:/home/Datasets/result_ymartel/egonet2.json")
