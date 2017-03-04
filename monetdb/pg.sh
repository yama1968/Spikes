#

mclient -s "drop table Node1"

mclient -s "
create table Node1
AS
select
  n.nodeid,
  n.nodeweight,
  CASE
                WHEN x.TargetNodeCount IS NULL THEN 10
                ELSE x.TargetNodeCount
                END AS nodecount,
	0 AS HasConverged
from Nodes n
left outer join
(
	select SourceNodeID,
	       count(*) AS TargetNodeCount
	from Edges
	group by SourceNodeId
) as x
on x.SourceNodeID = n.NodeId"

while [ 0 -ne $(mclient -f csv -s "
SELECT count(*)
  FROM Node1
 WHERE hasconverged = 0") ]
do
  mclient -f csv < pg_step.sql
done

mclient -s "select * from node1"
