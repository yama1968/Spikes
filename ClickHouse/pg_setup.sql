

DROP TABLE IF EXISTS Node1;

create table Node1
  ENGINE=Memory
AS
SELECT
       NodeId,
       NodeWeight,
       CASE
       WHEN cnt is null
       THEN 0
       ELSE cnt
       END AS NodeCount,
       0 as HasConverged
  FROM Nodes
   ANY LEFT JOIN (
SELECT
       SourceNodeId AS NodeId,
       COUNT(*) as cnt
  FROM Edges
 GROUP BY NodeId)
 USING (NodeId);
