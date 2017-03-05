#


ch="clickhouse-client -n"

clickhouse-client --query="drop table Node1"

$ch < pg_setup.sql

iteration=0

while [ 0 -ne 0$($ch --query="
SELECT count(*)
  FROM Node1
 WHERE HasConverged = 0") ]
do
  $ch < pg_step_opt.sql
  iteration=$(($iteration+1))
  echo $iteration iterations
  $ch -t --query="SELECT count(*), HasConverged From Node1 GROUP BY HasConverged ORDER BY HasConverged"
done

$ch --query="select avg(NodeWeight) from Node1"

# twitter time = 45 sec -> 42 sec / 0.77 -> 11 sec with clickhouse
# orkut time = 9 min -> 480 sec -> 7min20... bof!!!!
# soc / opt -> 9 min 37 en 46 itérations
