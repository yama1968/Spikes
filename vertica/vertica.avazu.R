require(vertica.dplyr)
require(data.table)

small_train_file <- "/media/sf_Documents/tmp/train10k.csv"
train_file <- "/media/sf_Documents/tmp/train.csv"
# train_file <- "/media/sf_Documents/tmp/train10k.csv"

small_train <- fread(small_train_file)

t.names <- names(small_train)
v.types <- rep("varchar", length(t.names))
v.types[2] <- "integer"
names(v.types) <- t.names

v <- src_vertica(dsn = "AvazuDSN")

if (db_has_table(v$con, "train")) {
  db_drop_table(v$con, "train")
}

db_create_table(v$con, "train", v.types)
system.time({
  db_load_from_file(v, "train", train_file, sep=",", skip=1L, append=FALSE)
})

# full
# utilisateur     système      écoulé 
# 7.739      39.923     501.373 

v.train <- tbl(v, "train")

system.time({
  c <- collect(v.train %>%
                 select(click) %>%
                 group_by(click) %>%
                 summarise(count=n()))
})
# utilisateur     système      écoulé 
# 0.180       0.000       3.898 
# hot and cold! with select -> 3.27

system.time({
  v.per.hour <- v.train %>%
    group_by(hour) %>%
    summarise(nb=n(), p=avg(click)) %>%
    arrange(hour)
  per.hour <- collect(v.per.hour)
})
# utilisateur     système      écoulé 
# 0.000       0.000      12.257 

plot(per.hour$nb, type='l')

system.time({
  v.per.device_ip <- v.train %>%
    group_by(device_ip) %>%
    summarise(nb=n(), p=avg(click)) %>%
    arrange(desc(nb))
})
system.time({
  per.device_ip <- collect(v.per.device_ip)
})
# utilisateur     système      écoulé 
# 133.398       0.000     189.470 
# cold = 210

plot(per.device_ip$nb[1:50], type='l')
hist(per.device_ip[1:1000]$p)

system.time({
  v.small.ip <- v.per.device_ip %>%
    filter(p < 0.05)
  small.ip <- collect(v.small.ip)
})
# utilisateur     système      écoulé 
# 58.504       1.148     124.432 

hist(small.ip$nb)

system.time({
  v.per.device_model <- v.train %>%
    select(device_model, click) %>%
    group_by(device_model) %>%
    summarise(nb=n(), p=avg(click)) %>%
    arrange(desc(nb))
  per.device_model <- collect(v.per.device_model)
})
# 
# utilisateur     système      écoulé 
# 0.070       0.012      15.431 

plot(log(per.device_model$nb[1:50]), type='l')

db_save_view(v.per.device_model, "per_device_model")

# mutation

system.time ({
  v.hod <- v.train %>%
    mutate(hod=substr(hour,7,2), day=substr(hour, 5,2))
})
v.hod %>% select(id, hod, day)

system.time({
  v.per.hour <- v.hod %>%
    group_by(hod) %>%
    summarise(nb=n(), p=mean(click)) %>%
    arrange(hod)
  per.hour <- collect(v.per.hour)
})
# écoulé: 6 sec


system.time({
  v.per.day.hour <- v.hod %>%
    group_by(day,hod) %>%
    summarise(nb=n(), p=mean(click)) %>%
    arrange(day,hod)
  per.day.hour <- collect(v.per.day.hour)
})


require(ggplot2)

a <- ggplot(per.hour, aes(hwy)) +
  geom_line(aes(x=hod, y=nb)) +
  geom_line(aes(x=hod, y=p))
a

q <- sqlQuery(v$con@conn, "select hour, count(*) from train group by hour order by hour")
q

a <- ggplot(per.day.hour, aes(x=hod, y=nb)) +
  geom_point(aes(color=day)) +
  geom_smooth()
a

a <- ggplot(per.day.hour, aes(x=factor(hod), y=nb)) +
  geom_boxplot()
a

a <- ggplot(per.day.hour, aes(x=factor(hod), y=p)) +
  geom_boxplot()
a

a <- ggplot(per.day.hour, aes(x=hod, y=p)) +
  geom_point(aes(color=day)) +
  geom_smooth()
a

a <- ggplot(per.day.hour, aes(factor(day), p)) +
  geom_boxplot()
a


# v.train %>% mutate(x=substr(hour,3,2)) %>% group_by(x) %>% summarise(nb=n())

