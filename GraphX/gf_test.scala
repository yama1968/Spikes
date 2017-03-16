
import org.apache.spark.sql.SparkSession

val spark = (SparkSession
  .builder()
  .appName("Spark SQL basic example")
  .config("spark.some.config.option", "some-value")
  .getOrCreate())

// For implicit conversions like converting RDDs to DataFrames
import spark.implicits._



import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType};

val customSchema = StructType(Array(StructField("src", IntegerType, true),
                                    StructField("dst", IntegerType, true)))
val df = (spark.read.format("org.apache.spark.sql.execution.datasources.csv.CSVFileFormat")
            .option("header", "false")
            .option("delimiter", " ")
            .schema(customSchema)
            .load("/home/yannick/Work/gitlab/vast08/data/twitter_combined.txt")
          )

val edges = df

import org.graphframes._
import org.graphframes.GraphFrame

val n1 = edges.select("src").distinct()
val n2 = edges.select("dst").distinct()
val n = n1.unionAll(n2).withColumnRenamed("src", "name").distinct()
val nodes = n.withColumn("id", n("name"))
edges.show()
nodes.show()
val g1 = GraphFrame(nodes, edges)

def time[A](f: => A) = {
  val s = System.nanoTime
  val ret = f
  println("time: "+(System.nanoTime-s)/1e6+"ms")
  ret
}

val pr2 = time(g1.pageRank.resetProbability(0.15).maxIter(10).run())

val pr3 = pr2.vertices.sort(desc("pagerank"))
