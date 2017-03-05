#

dataset=$1
offset=$2


clickhouse-client -n -m < "

DROP TABLE IF EXISTS Nodes;
DROP TABLE IF EXISTS Edges;

CREATE TABLE Nodes
(NodeId Int32
,NodeWeight Float32
,NodeCount Int32 default(0)
,HasConverged Int32 default(0)
)
ENGINE = Log;

CREATE TABLE Edges
(SourceNodeId Int32
,TargetNodeId Int32
)
ENGINE = Log;
"

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
