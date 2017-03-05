

CREATE TABLE Nodes_prime
ENGINE=Memory
AS
SELECT NodeId,
       CASE
          WHEN TransferredNodeWeight IS NULL
          THEN CAST(1 - 0.85 AS Float32)
          ELSE CAST(1 - 0.85 + TransferredNodeWeight AS Float32)
           END AS NodeWeight,
        Cast(NodeCount AS Int32) as NodeCount,
        CASE
          WHEN TransferredNodeWeight IS NULL
          THEN CAST(2 AS Int32)
          WHEN 0.001 >
            abs(OldWeight - (1.0 - 0.85 + TransferredNodeWeight))
          THEN CAST(1 + MinHasConverged AS Int32)
          ELSE CAST(0 AS Int32)
           END AS HasConverged
  FROM (
    SELECT NodeId,
           NodeWeight as OldWeight,
           NodeCount as NodeCount
      FROM Node1
     WHERE HasConverged < 1
  )
  ANY LEFT JOIN (
    SELECT
           NodeId,
           CAST(sum(NodeWeight / NodeCount) * 0.85 AS Float32)
                AS TransferredNodeWeight,
           CAST(min(HasConverged) AS Int32) AS MinHasConverged
      FROM (
           SELECT TargetNodeId AS NodeId,
                  SourceNodeId AS SourceNodeId
             FROM Edges
            WHERE NodeId <> SourceNodeId
     ) ANY LEFT JOIN (
           SELECT NodeId AS SourceNodeId,
                  NodeWeight,
                  NodeCount,
                  HasConverged
             FROM Node1
      ) USING (SourceNodeId)
    GROUP BY NodeId
  )
  USING (NodeId)
 UNION ALL
SELECT NodeId, NodeWeight,
       CAST(NodeCount AS Int32), CAST(HasConverged AS Int32)
  FROM Node1
 WHERE HasConverged >= 1;

DROP TABLE Node1;
CREATE TABLE Node1
ENGINE=Memory
AS
  SELECT * FROM Nodes_prime;
DROP TABLE Nodes_prime;
