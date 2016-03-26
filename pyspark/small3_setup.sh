#!/bin/bash

TRAIN=/media/sf_host/home2/yannick2/github/Spikes/pyspark/small3.train.csv

hdfs dfs -rm -skipTrash /user/cloudera/train.csv

sudo -u hdfs hive <<END

drop table train_csv;

END


cat < $TRAIN | tail -n +2 | hdfs dfs -put - /user/cloudera/train.csv
hdfs dfs -ls -h

hive <<END

create table train_csv (
id string, click int, hour string, C1 string, banner_pos string, site_id string, site_domain string, site_category string, app_id string, app_domain string, app_category string, device_id string, device_ip string, device_model string, device_type string, device_conn_type string, C14 string, C15 string, C16 string, C17 string, C18 string, C19 string, C20 string, C21 string
)
row format delimited fields terminated by ',';

load data inpath '/user/cloudera/train.csv'
   into table train_csv;

select * from train_csv limit 1;

END


hdfs dfs -ls -h

PATH=/usr/local/firefox:/sbin:/usr/java/jdk1.7.0_67-cloudera/bin:/usr/local/apache-ant/apache-ant-1.9.2/bin:/usr/local/apache-maven/apache-maven-3.0.4/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/cloudera/bin impala-shell <<END
set compression_codec=snappy;

invalidate metadata;

drop table train;

create table train (
id string, click int, hour string, C1 string, banner_pos string, site_id string, site_domain string, site_category string, app_id string, app_domain string, app_category string, device_id string, device_ip string, device_model string, device_type string, device_conn_type string, C14 string, C15 string, C16 string, C17 string, C18 string, C19 string, C20 string, C21 string
)
stored as parquetfile;

insert into train select * from train_csv;

select * from train limit 1;

END

