#!/bin/bash

if [ "x$1" = "x" ]; then
  read -p "Project name: " PNAME
else
  PNAME=$1
fi

IFS="-_" read -r -a PARTS <<< "$PNAME"
ONAME=""
for PART in "${PARTS[@]}"; do
    ONAME="${ONAME}$(tr '[:lower:]' '[:upper:]' <<< ${PART:0:1})${PART:1}"
done

mkdir -p $PNAME/src/main/scala

cd $PNAME

# SPARK_VERSION="1.6.2.2.5.0.0-1245"
# SCALA_MAJOR_VERSION="2.10"
# SCALA_MINOR_VERSION="6"
SPARK_VERSION="2.0.0.2.5.0.0-1245"
SCALA_MAJOR_VERSION="2.11"
SCALA_MINOR_VERSION="8"

SCALA_VERSION="${SCALA_MAJOR_VERSION}.${SCALA_MINOR_VERSION}"

PROVIDED='% "provided"'
PROVIDED=""

cat << EOF > src/main/scala/$ONAME.scala
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
// import org.apache.spark.sql.functions._
// import org.apache.spark.sql.hive.HiveContext

import scala.collection.JavaConverters._
import scala.collection.JavaConversions._

import org.apache.log4j.{Level, Logger}


object $ONAME {

  def main(args: Array[String]) = {
    
    var conf = new SparkConf().setAppName("$PNAME")
                              .setMaster("local[*]")
    val sc = new SparkContext(conf)
    Logger.getRootLogger.setLevel(Level.ERROR)

    // val sqlContext = new HiveContext(sc)
    // import sqlContext.implicits._
    // sqlContext.setConf("hive.exec.dynamic.partition", "true")
    // sqlContext.setConf("hive.exec.dynamic.partition.mode", "nonstrict")

    println(s"Hello Spark \${sc.version}")
    sc.stop()
  }
}
EOF

cat << EOF2 > build.sbt
name := "$ONAME"

version := "1.0.0"

scalaVersion := "$SCALA_VERSION"

resolvers += "Hortonworks Repository" at "http://repo.hortonworks.com/content/repositories/releases/"
resolvers += "Hortonworks Jetty Maven Repository" at "http://repo.hortonworks.com/content/repositories/jetty-hadoop/"

libraryDependencies ++= Seq(
  // "com.betaocean" % "logoverhttp_${SCALA_MAJOR_VERSION}" % "1.0.0",
  "log4j"            % "log4j"           % "1.2.14",
  "org.apache.spark" % "spark-sql_${SCALA_MAJOR_VERSION}"  % "$SPARK_VERSION" $PROVIDED,
  "org.apache.spark" % "spark-hive_${SCALA_MAJOR_VERSION}" % "$SPARK_VERSION" $PROVIDED
)
EOF2

mkdir project
cat << EOF3 > project/plugins.sbt
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.3")
EOF3

subl .