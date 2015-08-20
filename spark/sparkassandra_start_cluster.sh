#

# run a Spark master
docker run -d -t -P --name spark_master clakech/sparkassandra-dockerized /start-master.sh

# run a Cassandra + Spark worker node
docker run -it --name some-cassandra --link spark_master:spark_master -d clakech/sparkassandra-dockerized

# (optional) run some other nodes if you wish
docker run -it --link spark_master:spark_master --link some-cassandra:cassandra -d clakech/sparkassandra-dockerized

