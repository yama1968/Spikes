
create table Node1
AS
select
  n.nodeid,
  n.nodeweight,
  CASE
                WHEN x.TargetNodeCount IS NULL THEN -1
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
on x.SourceNodeID = n.NodeId;
