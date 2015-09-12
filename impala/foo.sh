hdfs dfs -put /home/cloudera/Downloads/train100k.csv /user/cloudera/train100k.csv

gunzip < train.gz | tail -n +2 | head -1000000 | hdfs dfs -put - /user/cloudera/train1M.csv
gunzip < train.gz | tail -n +2 | hdfs dfs -put - /user/cloudera/train.csv

hdfs dfs -ls
