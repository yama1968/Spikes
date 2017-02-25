DROP TABLE Nodes;
DROP TABLE Edges;

CREATE TABLE Nodes
(NodeId int not null
,NodeWeight decimal(10,5)
,NodeCount int not null default(0)
,HasConverged int not null default(0)
);

CREATE TABLE Edges
(SourceNodeId int not null
,TargetNodeId int not null
);

delete from Nodes;

delete from Edges;


INSERT INTO Nodes
(NodeId
,NodeWeight
,HasConverged)
VALUES
(1,0.25,0)
,(2,0.25,0)
,(3,0.25,0)
,(4,0.25,0);

INSERT INTO Edges
(SourceNodeId
,TargetNodeId)
VALUES
(2,1) --page 2 links to pages 1 and 3
,(2,3)
,(3,1) --page 3 links to page 1
,(4,1) -- page 4 links to the 3 other pages
,(4,2)
,(4,3);




-- Running PageRank
DECLARE DampingFactor int;
    SET DampingFactor = 0.85;
DECLARE MarginOfError decimal(10,5);
    SET MarginOfError = 0.001;

 CREATE FUNCTION TotalNodeCount()
RETURNS int
  BEGIN 
        RETURN select count(*) from Nodes;
   END;

 CREATE FUNCTION is_null(a int, b int)
RETURNS int
  BEGIN
        IF a IS NULL
        THEN RETURN b;
        ELSE RETURN a;
        END IF;
    END;

update Nodes
set 
	NodeCount = is_null(x.TargetNodeCount,TotalNodeCount()), --store the number of edges each node has pointing away from it.
	-- if a node has 0 edges going away (it's a sink), then its number is the total number of edges in the system.
	HasConverged = false
from Nodes n
left outer join
(
	select SourceNodeID,
	       count(*) AS TargetNodeCount
	from Edges
	group by SourceNodeId
) as x
on x.SourceNodeID = n.NodeId;


-- select * from Nodes


declare DampingFactor decimal(3,2);
    SET DampingFactor = 0.85;
DECLARE MarginOfError decimal(10,5);
    SET MarginOfError = 0.001;
DECLARE TotalNodeCount int;
DECLARE IterationCount int;
    SET IterationCount = 1;

DECLARE foo int;
    SET foo = 1;

 CREATE PROCEDURE bar()
  BEGIN
        set foo = foo + 1;
    END;


 CREATE VIEW nodes_x
 AS
 	-- Compute the PageRank each target node by the sum
		-- of the nodes' weights that point to it.
		SELECT
			e.TargetNodeId
			,sum(n2.NodeWeight / n2.NodeCount) * DampingFactor AS TransferredNodeWeight
		FROM Nodes n2
		INNER JOIN Edges e
		  ON n2.NodeId = e.SourceNodeId
		WHERE e.SourceNodeId <> e.TargetNodeId --self references are ignored
		GROUP BY e.TargetNodeId;


 CREATE PROCEDURE PG()
BEGIN
WHILE EXISTS
(
	SELECT true
	FROM Nodes
	WHERE HasConverged = 0
)
DO
	CREATE TABLE Nodes_prime
	AS SELECT
		n.NodeId,
		case
			when x.TransferredNodeWeight IS NULL
			then 1 - DampingFactor
			else 1 - DampingFactor + x.TransferredNodeWeight
		end AS NodeWeight,
		n.NodeCount,
		case 
			when x.TransferredNodeWeight is NULL
			then 1
			when abs(n.NodeWeight - (1.0 - DampingFactor + x.TransferredNodeWeight)) < MarginOfError 
			then 1 
			else 0 
		END AS HasConverged
	FROM Nodes n
	LEFT OUTER JOIN Nodes_x as x
	on x.TargetNodeId = n.NodeId;

	delete  from Nodes;
	INSERT INTO Nodes
		SELECT * FROM Nodes_prime;
	DROP TABLE Nodes_prime;

	select
		IterationCount as IterationCount
		,*
	from Nodes;

	set IterationCount = IterationCount + 1;
END WHILE;
END;
