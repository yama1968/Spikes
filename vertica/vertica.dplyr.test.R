
require(vertica.dplyr)

# v <- src_vertica(dsn = NULL, jdbcpath="/opt/vertica/java/lib/vertica_jdbc.jar",
#                  "Y01","localhost",5433,"dbadmin", mypwd)

v <- src_vertica(dsn = "Y01DSN")

test <- tbl(v, "test") 

# require(nycflights13)
# head(flights, 10)
#flights_vertica <- copy_to(vertica, flights, "flights")

flights_vertica <- tbl(v, "flights")

q1 <- flights_vertica %>%
  filter (month == 1) %>%
  select(year, month, day, origin, arr_delay, flight)

q3 <- filter(q1, !is.na(arr_delay))
by_origin <- group_by(q3, origin)
q4 <- summarise(by_origin,
                count = n(),
                delay = mean(arr_delay))
q5 <- arrange(q4, desc(delay))

airport_delays <- collect(q5)
barplot(airport_delays[["delay"]],horiz=TRUE,
        names.arg=airport_delays[["origin"]],
        xlab="Average delay in minutes",ylab="Airport")


