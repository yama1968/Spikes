set compression_codec=snappy

create table train (
id string, click int, hour string, C1 string, banner_pos string, site_id string, site_domain string, site_category string, app_id string, app_domain string, app_category string, device_id string, device_ip string, device_model string, device_type string, device_conn_type string, C14 string, C15 string, C16 string, C17 string, C18 string, C19 string, C20 string, C21 string
)
stored as parquetfile;

insert into train select * from train_csv;
# 510 sec

load data inpath '/user/cloudera/data/train1M.csv' into table train;

compute stats train;


select count(*), click from train group by click;
# 2 sec

select banner_pos, count(*), avg(click) from train group by banner_pos;
# 8 sec

create view train2 as select substr(hour, 5, 2) as day, substr(hour, 7,2) as hod, click, id from train;
select day, count(*), avg(click) from train2 group by day;
# 3 sec

select hod, count(*) as nb, avg(click) as p from train2 group by hod order by hod;
# 3.3 sec
