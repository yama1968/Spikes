
library(dplyr)

con <- DBI::dbConnect(RClickhouse::clickhouse(), host = "localhost",
          port = 8123L, user = "default", password = "")

train <- tbl(con, "Train")

