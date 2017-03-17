
library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "local",
                    config = spark_config("spark.yml"))

system.time( df <- spark_read_parquet(sc,
                                      name = "train",
                                      path = "/home/yannick/tmp/train.parquet",
                                      repartition = 0,
                                      memory = FALSE) )

df1 <- df %>%
  mutate(click_day = substr(hour, 1, 6),
         click_hour = substr(hour, 7, 8)) %>%
  group_by(device_id, click_day) %>%
  arrange(hour, id) %>%
  mutate(nb = row_number())

df2.path <- "/home4/yannick4/tmp/aug.parquet"

spark_write_parquet(df1 %>% select(id, click, device_id, click_day, click_hour, nb),
                    path = df2.path)

df2 <- spark_read_parquet(sc, "df2", df2.path, memory = FALSE)

df2 %>%
  arrange(desc(nb)) %>%
  head(20)

max_in_day <- df2 %>%
  group_by(device_id, click_day) %>%
  filter(nb == max(nb))

nb_device_id <- max_in_day %>%
  group_by(nb) %>%
  summarise(cnt = n()) %>%
  arrange(desc(cnt))

nb_device_id_R <- nb_device_id %>% collect

##

library(ggplot2)

qplot(nb, cnt, data = nb_device_id_R, log = "xy")

##

max_in_day %>%
  filter(nb > 1e5)

max_in_day_tbl <- sdf_register(max_in_day, name = "max_in_day")
tbl_cache(sc, "max_in_day")

system.time(max_in_day_tbl %>% collect)
system.time(max_in_day %>% collect)

DBI::dbGetQuery(sc, "select * from max_in_day where click_day = '141022' and click_hour = '15' order by nb desc limit 20")

spark_disconnect(sc)
