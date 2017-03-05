
declare DampingFactor decimal(3,2);
    SET DampingFactor = 0.85;

DECLARE MarginOfError decimal(10,5);
    SET MarginOfError = 0.01;


CREATE TABLE Nodes_prime
AS
SELECT Y.NodeId AS NodeID,
       CASE
          WHEN X.TransferredNodeWeight IS NULL
          THEN 1 - DampingFactor
          ELSE 1 - DampingFactor + X.TransferredNodeWeight
           END AS NodeWeight,
        Y.NodeCount as NodeCount,
        CASE
          WHEN X.TransferredNodeWeight IS NULL
          THEN 2
          WHEN MarginOfError >
            ABS(Y.NodeWeight - (1.0 - DampingFactor + X.TransferredNodeWeight))
          THEN 1 + X.MinHasConverged
          ELSE 0
           END AS HasConverged
  FROM (
    SELECT *
      FROM Node1
     WHERE HasConverged < 1
  ) AS Y
  LEFT OUTER JOIN (
    SELECT
           E.TargetNodeId AS TargetNodeId,
           sum(Z.NodeWeight / Z.NodeCount) * 0.85 AS TransferredNodeWeight,
           min(Z.HasConverged) AS MinHasConverged
      FROM Node1 Z
     INNER JOIN Edges E
        ON Z.NodeId = E.SourceNodeId
     WHERE E.SourceNodeId <> E.TargetNodeId --self references are ignored
     GROUP BY E.TargetNodeId
  ) AS X
    ON X.TargetNodeId = Y.NodeId
 UNION
SELECT NodeId, NodeWeight, NodeCount, HasConverged
  FROM Node1
 WHERE HasConverged >= 1;

DELETE FROM Node1;
INSERT INTO Node1
  SELECT * FROM Nodes_prime;
DROP TABLE Nodes_prime;
