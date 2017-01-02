import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// import org.apache.spark.sql.functions._
// import org.apache.spark.sql.hive.HiveContext

import scala.collection.JavaConverters._
import scala.collection.JavaConversions._

import org.apache.log4j.{Level, Logger}


object TestProject {

  def main(args: Array[String]) = {
    var conf = new SparkConf().setAppName("test-project")
                              .setMaster("local[*]")
    val sc = new SparkContext(conf)
    Logger.getRootLogger.setLevel(Level.ERROR)

    // val sqlContext = new HiveContext(sc)
    // import sqlContext.implicits._
    // sqlContext.setConf("hive.exec.dynamic.partition", "true")
    // sqlContext.setConf("hive.exec.dynamic.partition.mode", "nonstrict")

    println(s"Hello Spark ${sc.version}")
    sc.stop()
  }
}
