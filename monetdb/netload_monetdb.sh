#

dataset=$1
offset=$2


mclient -s "
delete from Edges"

mclient -s "
delete from Nodes"

mclient -s "
copy offset $offset into Edges
     from '/home/yannick/Work/gitlab/vast08/data/$dataset'
     delimiters ' '
     locked
"

mclient -s "
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

# orkut.txt -> time = 26 sec
