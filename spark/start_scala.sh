#

# run a Spark shell 
docker run -i -t -P --link spark_master:spark_master --rm -v /media/sf_Documents:/mnt --link some-cassandra:cassandra clakech/sparkassandra-dockerized /spark-shell.sh
