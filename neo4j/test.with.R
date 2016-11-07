

library(igraph)
library(visNetwork)
library(RNeo4j)

graph = startGraph("http://localhost:7474/db/data/", username = "neo4j", password = p)
importSample(graph, "movies", input=F)

query = "
MATCH (p1:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(p2:Person)
WHERE p1.name < p2.name
RETURN p1.name AS from, p2.name AS to, COUNT(*) AS weight
"

edges = cypher(graph, query)

head(edges)

nodes = data.frame(id=unique(c(edges$from, edges$to)))
nodes$label = nodes$id

visNetwork(nodes, edges)

ig = graph_from_data_frame(edges, directed=F)
nodes$value = betweenness(ig)
visNetwork(nodes, edges)

