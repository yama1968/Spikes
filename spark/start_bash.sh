
# run a Cassandra cqlsh console 

docker run -it --link some-cassandra:cassandra -v /media/sf_Documents:/mnt clakech/sparkassandra-dockerized bash
