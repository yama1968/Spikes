#

// run with 6GB RAM for spark in spark-defaults.conf

import org.apache.spark.graphx._

def time[A](f: => A) = {
  val s = System.nanoTime
  val ret = f
  println("time: "+(System.nanoTime-s)/1e6+"ms")
  ret
}

val dir = "file:/media/sf_yannick/Work/gitlab/vast08/data/"
val dir = "/home/yannick/Work/gitlab/vast08/data/"


// val graph = GraphLoader.edgeListFile(sc, dir + "facebook_combined.txt")
val g = time { GraphLoader.edgeListFile(sc, dir + "twitter_combined.txt") }
// 3 sec
// val graph = time { GraphLoader.edgeListFile(sc, dir + "soc-LiveJournal1.txt") }
// 28 sec


var np = 8
val graph = time { Graph(g.vertices.repartition(np),
                         g.edges.repartition(np))}

time { graph.cache() }


val l = graph.inDegrees.reduce((a,b) => if (a._2 > b._2) a else b)

val v = time { graph.pageRank(0.001).vertices }
// 50 sec sur twitter, blurg sur soc.. Mémoire?

time { v.reduce((a,b) => if (a._2 > b._2) a else b) }

val graph = time { GraphLoader.edgeListFile(sc, dir + "soc-LiveJournal1.txt") }
//
graph.vertices.partitions.size
