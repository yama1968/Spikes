
require(vertica.dplyr)

v <- src_vertica(dsn = "VMartDSN")

products <- tbl(v, "product_dimension") 

p1 <- products %>% 
  select(fat_content, product_description) %>% 
  filter(fat_content >= 80) %>%
  arrange(desc(fat_content))

products %>%
  select(fat_content, product_key) %>%
  group_by(department_description, fat_content) %>%
  summarise(count = n()) %>%
  arrange(desc(fat_content))

products %>%
  summarise(count = n())

products %>%
  select(fat_content, product_key, department_description) %>%
  group_by(department_description) %>%
  summarise(count=n(), avg_fat=mean(fat_content)) %>%
  arrange(desc(avg_fat))

customers <- tbl(v, "customer_dimension")

ssf <- tbl(v, "store.store_sales_fact")
system.time({ 
  by_shop <- ssf %>%
    select(store_key, sales_dollar_amount) %>%
    group_by(store_key) %>%
    summarise(count=n(), all_sales=sum(sales_dollar_amount)) %>%
    arrange(desc(all_sales))
  
  b <- collect(by_shop)
})

system.time({ 
  local_ssf <- collect(ssf)
})

system.time({ 
  local_by_shop <- local_ssf %>%
    select(store_key, sales_dollar_amount) %>%
    group_by(store_key) %>%
    summarise(count=n(), all_sales=sum(sales_dollar_amount)) %>%
    arrange(desc(all_sales))
})


