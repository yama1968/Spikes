
library(DBI)
library(dplyr)

con <- dbConnect(MonetDB.R::MonetDB.R(), host = "localhost",
                 dbname = "db", user = "monetdb", password = "monetdb")
foo <- dbGetQuery(con, "select * from Train limit 1000")

names(foo)

system.time(distinct.device_ip <-
              dbGetQuery(con, "select count(distinct(device_ip)) from train"))
distinct.device_ip
# 8 sec

system.time(count.device_ip <-
              dbGetQuery(con, "select device_ip, count(*) as cnt
                                 from train
                                group by device_ip
                                order by cnt desc"))
# 24 sec

system.time({
  foo <-
    dbGetQuery(conn = con,
               "select * from train where banner_pos = '3'")
})
foo

