
library(igraph)
karate <- make_graph("Zachary")
karate$layout <- layout_with_kk(karate)
plot(karate)

fc <- cluster_fast_greedy(karate)
memb <- membership(fc)
plot(karate, vertex.color=memb)

edge.list<-data.frame(get.edgelist(karate,names=TRUE))
edge.list$ID<-"friends"
head(edge.list)

nodes<-as.matrix(V(karate))
node.data<-data.frame(ID=nodes,group=as.matrix(memb))
#add color
node.data$color<-rainbow(length(unique(node.data$group)))[factor(node.data$group)]
#add size based on centrality
#rescale to 20-60
library(scales)
node.data$size<-rescale(closeness(karate, mode="all"),to=c(10,40))
head(node.data)


library(networkly)
#net params
layout<-"kamadakawai"
type<-"2d"
color<-'color'
size<-'size'
name<-'ID'
obj<-get_network(edge.list,type=type,layout=layout)

#create plotting attributes
net<-c(get_edges(obj,color=NULL,width=NULL,name=name,type=type,hoverinfo="none",showlegend=FALSE),
       get_nodes(obj,node.data,color=color,size=size,name=name,
                 type=type,hoverinfo="ID",showlegend=FALSE),
       get_text(obj,node.data,text=name,extra=list(textfont=list(size=20)),
                type=type,yoff=-5,hoverinfo="none",showlegend=FALSE))
#visualize
shiny_ly(net)
