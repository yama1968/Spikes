#

dataset=$1
offset=$2


clickhouse-client --query="
delete from Edges"

clickhouse-client --query="
delete from Nodes"

tail -n +$offset /home/yannick/Work/gitlab/vast08/data/$dataset |  \
tr ' ' ',' | \
	clickhouse-client --query="INSERT INTO Edges FORMAT CSV"

clickhouse-client --query="
INSERT INTO Nodes
SELECT NodeId,
			 CAST(1.0 AS Float32) AS NodeWeight,
		   CAST(0 AS Int32) as NodeCount,
			 CAST(0 AS Int32) as HasConverged
  FROM (
    SELECT SourceNodeId AS NodeId
      FROM Edges
     UNION ALL
    SELECT TargetNodeId AS NodeId
      FROM Edges
  )
	GROUP BY NodeId
"
