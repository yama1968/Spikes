#

library(DBI)
library(dplyr)

con <- dbConnect(clickhouse::clickhouse(), host = "localhost",
                 port = 8123L, user = "default", password = "")
foo <- dbGetQuery(con, "select * from Train limit 1000")

names(foo)

system.time(distinct.device_ip <-
              dbGetQuery(con, "select count(distinct(device_ip)) from train"))
distinct.device_ip

system.time(count.device_ip <-
              dbGetQuery(con, "select device_ip, count(*) as cnt
                                 from train
                                group by device_ip
                                order by cnt desc"))
# 8 secs!

count.device_ip %>%
  head(20)

system.time(count.8a014cbb <-
              dbGetQuery(con,"
SELECT substring(hour, 1, 6) AS day,
       count(*) AS clicks_per_day
  FROM (
       SELECT *
         FROM train
        WHERE device_ip = '8a014cbb'
  )
 GROUP BY day
 ORDER BY day"))
count.8a014cbb

count_per_hour <- function(h) {
  dbGetQuery(con, paste0("
SELECT hour,
       count(*) AS clicks_per_hour
  FROM (
       SELECT *
         FROM train
        WHERE device_ip = '", h, "'
  )
 GROUP BY hour
 ORDER BY hour"))
}

system.time(cph <- count_per_hour("8a014cbb"))

library(lubridate)
library(ggplot2)
library(lubridate)

cph_time <- ymd(substr(cph$hour, 1, 6)) + hours(substr(cph$hour, 7, 8))
qplot(cph_time, clicks_per_hour, data = cph, geom = "line")

gph <- dbGetQuery(con, "
SELECT hour,
       count(*) as clicks_per_hour
  FROM train
 GROUP BY hour
 ORDER BY hour
              ")

gph_time <- ymd(substr(gph$hour, 1, 6)) + hours(substr(gph$hour, 7, 8))
qplot(gph_time, clicks_per_hour, data = gph, geom = "line")
