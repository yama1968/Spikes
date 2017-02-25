#

library(sparklyr)
library(dplyr)
sc <- spark_connect(maste = "local",
                    config = spark_config("spark.yml"))

system.time(df1 <- spark_read_csv(sc, name = "train10k", path = "/home/yannick/tmp/train10k.csv", repartition = 4, memory = TRUE, overwrite = TRUE))

system.time(foo <- df1 %>% group_by(click) %>% summarise(cnt = count()) %>% collect)
foo

system.time(df <- spark_read_csv(sc, name = "train", path = "/home/yannick/tmp/train.csv", repartition = 4, memory = TRUE, overwrite = TRUE))
# 250 sec

system.time(foo <- df %>% group_by(click) %>% summarise(cnt = count()) %>% collect)
# 1.2 sec!!!
foo

library(DBI)
system.time(foo <- dbGetQuery(sc, "select banner_pos, count(*) as nb, avg(click) as p
       from train
       group by banner_pos
       order by banner_pos"))
foo
# 2 sec!!

system.time(foo <- dbGetQuery(sc,"
       select device_type, count(*) as nb, avg(click) as p
       from train
       group by device_type
       order by nb desc"))
foo
# 1.3 sec

dbGetQuery(sc, "select count(*) from train")
#
# system.time(dbGetQuery(sc, "
#       create view device_id_type
#        as select device_id, device_type, count(*) as nb
#        from train
#        group by device_id, device_type"))
# system.time(dbGetQuery(sc, "
#       create view device_id
#        as select device_id, count(*) as nnb, sum(nb) as snb
#        from device_id_type
#        group by device_id"))

device_id_type <- df %>%
  group_by(device_id, device_type) %>%
  summarise(nb = count())

device_id <- device_id_type %>%
  group_by(device_id) %>%
  summarise(nnb = count(), snb = sum(nb))

system.time(nnb <- device_id %>%
              filter(nnb >= 2) %>%
              group_by(nnb) %>%
              summarise(cnt = count()) %>%
              arrange(desc(nnb)) %>%
              collect)
nnb
# 4 secs!


train3 <- df %>%
  mutate(int_day = substr(hour, 5, 2),
         int_hour = substr(hour, 7, 2))
train3 %>% select(id, int_day, int_hour)

device_plus_dt <- train3 %>%
  group_by(device_id, device_ip, int_day) %>%
  arrange(int_hour) %>%
  select(device_id, device_ip,
         int_day, int_hour) %>%
  mutate(dt_hour = int_hour - lag(int_hour)) %>%
  ungroup()

device_plus_dt %>%
  filter(is.null(dt_hour)) %>%
  count()
# crash on 1.6!!!

system.time(
dt_per_day <- device_plus_dt %>%
  select(!is.null(dt_hour)) %>%
  group_by(int_day) %>%
  summarise(sum_dt_hour = sum(dt_hour),
            num_per_day = count(),
            avg_per_day = sum(dt_hour) / count(dt_hour)) %>%
  arrange(int_day) %>%
  collect
)
dt_per_day





