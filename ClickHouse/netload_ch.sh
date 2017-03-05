#

dataset=$1
offset=$2


clickhouse-client --query="
delete from Edges"

clickhouse-client --query="
delete from Nodes"

tail -n +$offset /home/yannick/Work/gitlab/vast08/data/$dataset | \
	clickhouse-client --query="INSERT INTO Edges FORMAT CSV"

clickhouse-client --query="
INSERT INTO Nodes
SELECT NodeId, 1, 0, 0
  FROM (
    SELECT SourceNodeId AS NodeId
      FROM Edges
     UNION
    SELECT TargetNodeId AS NodeId
      FROM Edges
  ) AS N
 GROUP BY NodeId
"
