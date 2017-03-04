

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
