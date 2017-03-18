

library(DBI)

if (!"con" %in% ls())
  con <- dbConnect(clickhouse::clickhouse(), host = "localhost",
                   port = 8123L, user = "default", password = "")

system.time({
  foo <-
    dbGetQuery(conn = con,
               "select * from train where banner_pos = '3'")
})

head(foo, 20)
