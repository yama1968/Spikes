create table train_csv (
id string, click int, hour string, C1 string, banner_pos string, site_id string, site_domain string, site_category string, app_id string, app_domain string, app_category string, device_id string, device_ip string, device_model string, device_type string, device_conn_type string, C14 string, C15 string, C16 string, C17 string, C18 string, C19 string, C20 string, C21 string
)
row format delimited fields terminated by ',';


load data local inpath '/home/cloudera/Downloads/train100k.csv' 
into table train_csv;

load data local inpath '/home/cloudera/Downloads/train-1.csv' 
into table train_csv;

load data local inpath '/home/cloudera/Downloads/train.gz' 
into table train_csv;


# loading 5.9 GB!
# 


