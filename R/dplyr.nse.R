

library(dplyr)
library(lazyeval)

data(cars)

f <- function (col1, col2, new_col_name) {
        mutate_call <- lazyeval::interp(~a/b,
                                        a=as.name(col1),
                                        b=as.name(col2))
        mtcars %>%
                mutate_(.dots=setNames(list(mutate_call), new_col_name))
}

head(f('disp', 'cyl', 'zoobar'))
