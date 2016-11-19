#

# run with 6GB RAM for spark in spark-defaults.conf

import org.apache.spark.graphx._

def time[A](f: => A) = {
  val s = System.nanoTime
  val ret = f
  println("time: "+(System.nanoTime-s)/1e6+"ms")
  ret
}


val graph = GraphLoader.edgeListFile(sc, "file:/local/Work/gitlab/vast08/data/facebook_combined.txt")
val graph = time { GraphLoader.edgeListFile(sc, "file:/local/Work/gitlab/vast08/data/twitter_combined.txt").cache }
# 3 sec
val graph = time { GraphLoader.edgeListFile(sc, "file:/local/Work/gitlab/vast08/data/soc-LiveJournal1.txt").cache }
# 28 sec

val l = graph.inDegrees.reduce((a,b) => if (a._2 > b._2) a else b)




val v = time { graph.pageRank(0.001).vertices }
# 50 sec sur twitter, blurg sur soc.. Mémoire?

time { v.reduce((a,b) => if (a._2 > b._2) a else b) }
