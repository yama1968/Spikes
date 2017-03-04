
declare DampingFactor decimal(3,2);
    SET DampingFactor = 0.85;

DECLARE MarginOfError decimal(10,5);
    SET MarginOfError = 0.001;

CREATE TABLE Nodes_prime
AS SELECT
  n.NodeId AS NodeId,
  case
    when x.TransferredNodeWeight IS NULL
    then 1 - DampingFactor
    else 1 - DampingFactor + x.TransferredNodeWeight
  end AS NodeWeight,
  n.NodeCount AS NodeCount,
  case
    when x.TransferredNodeWeight is NULL
    then 1
    when abs(n.NodeWeight - (1.0 - DampingFactor + x.TransferredNodeWeight)) < MarginOfError
    then 1
    else 0
  END AS HasConverged
FROM Node1 n
LEFT OUTER JOIN (
  SELECT
    e.TargetNodeId AS TargetNodeId,
    sum(n2.NodeWeight / n2.NodeCount) * 0.85 AS TransferredNodeWeight
  FROM Node1 n2
  INNER JOIN Edges e
    ON n2.NodeId = e.SourceNodeId
  WHERE e.SourceNodeId <> e.TargetNodeId --self references are ignored
  GROUP BY e.TargetNodeId
) as x
on x.TargetNodeId = n.NodeId;

DELETE FROM Node1;
INSERT INTO Node1
  SELECT * FROM Nodes_prime;
DROP TABLE Nodes_prime;
