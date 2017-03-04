#

mclient < pg_init.sql

while [ 0 -ne $(mclient -f csv < pg_test.sql) ]
do
  mclient -f csv < pg_step.sql
done

mclient -s "select * from nodes"
