

# devtools::install_github("hannesmuehleisen/MonetDBLite",ref="fcb21f4c4223024922221d4ed1a8e78d647d8abe")


library(MonetDBLite)
library(dplyr)

db <- src_monetdb(dbname = "db", user = "monetdb", password = "monetdb")
db

train <- tbl(db, "train")

train %>% summarise(cnt = n())
train %>%
  group_by(click) %>%
  summarise(cnt = n())

####

device_id_type <- train %>%
  group_by(device_id, device_type) %>%
  summarise(nb = n())

device_id <- device_id_type %>%
  group_by(device_id) %>%
  summarise(nnb = n(), snb = sum(nb))

system.time(nnb <- device_id %>%
              filter(nnb >= 2) %>%
              group_by(nnb) %>%
              summarise(cnt = n()) %>%
              arrange(desc(nnb)) %>%
              collect)
nnb

# 4.8 sec


