#

mclient -s "drop table Node1"

mclient -f csv < pg_setup.sql

iteration=0

while [ 0 -ne $(mclient -f csv -s "
SELECT count(*)
  FROM Node1
 WHERE hasconverged = 0") ]
do
  mclient -i -f csv < pg_step_opt.sql
  iteration=$(($iteration+1))
  echo $iteration iterations
  mclient -i -s "SELECT count(*), HasConverged From Node1 GROUP BY HasConverged ORDER BY HasConverged"
done

mclient -s "select avg(NodeWeight) from node1"

# twitter time = 45 sec -> 42 sec / 0.77
# orkut time = 9 min -> 480 sec
# soc / opt -> 9 min 37 en 46 itérations
