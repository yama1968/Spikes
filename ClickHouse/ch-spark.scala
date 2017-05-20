
import spark.implicits._

import io.clickhouse.ext.ClickhouseConnectionFactory
  import io.clickhouse.ext.spark.ClickhouseSparkExt._
  import org.apache.spark.sql.SparkSession

import org.apache.spark.sql.SparkSession

val spark = SparkSession
  .builder()
  .appName("Spark SQL basic example")
  .getOrCreate()

spark.sql("show tables").show()

val jdbc_string = "jdbc:clickhouse://localhost:8123"

val jdf = spark.read
  .format("jdbc")
  .option("driver", "ru.yandex.clickhouse.ClickHouseDriver" )
  .option("url", jdbc_string)
  .option("dbtable", "default.Train")
  .load()

jdf.groupBy("click").count().show()

implicit val ch = ClickhouseConnectionFactory.get("localhost")
