#!/bin/bash

# HDP 2.5.0
# SPARK1_VERSION="1.6.2.2.5.0.0-1245"
# SPARK2_VERSION="2.0.0.2.5.0.0-1245"
# HIVE_EXCLUDES=""
# HDP 2.5.3
SPARK1_VERSION="1.6.2.2.5.3.0-37"
SPARK2_VERSION="2.0.0.2.5.3.0-37"
HIVE_EXCLUDES="excludeAll(ExclusionRule(organization = \"org.spark-project.hive\"))"

SBT_ASSEMBLY_VERSION="0.14.3"

# Default values

SPARK_MAJOR_VERSION=2
SCALA_MAJOR_VERSION=2.11
PROVIDED=""
SPARK=1
JAVA=0

#
# Parse Parameters and set variables
#
function usage {
  echo "$(basename $0) --scala10 | --scala11 | --spark1 | --spark2 | --java [--provided]"
  exit 1
}

while [ $# -gt 0 ]; do
  case $1 in
    --java)                               SPARK=0; JAVA=1 ;;
    --scala10)  SCALA_MAJOR_VERSION=2.10; SPARK=0; JAVA=0 ;;
    --scala11)  SCALA_MAJOR_VERSION=2.11; SPARK=0; JAVA=0 ;;
    --spark1)   SPARK_MAJOR_VERSION=1     SPARK=1; JAVA=0 ;;
    --spark2)   SPARK_MAJOR_VERSION=2     SPARK=1; JAVA=0 ;;
    --provided) PROVIDED='% "provided"' ;;
    --help)     usage ;;
    -h)         usage ;;
    *)  break ;;
  esac
  shift
done

if [ $SPARK -eq 1 ]; then
  if [ $SPARK_MAJOR_VERSION -eq 1 ]; then
    echo "Creating project for Spark 1.6.2 with Scala 2.10"
    SPARK_VERSION="$SPARK1_VERSION"
    SCALA_MAJOR_VERSION="2.10"
  else
    echo "Creating project for Spark 2.0.0 with Scala 2.11"
    SPARK_VERSION="$SPARK2_VERSION"
    SCALA_MAJOR_VERSION="2.11"
  fi

  if [ "x$PROVIDED" == "x" ]; then
    echo "App will run in sbt leading to large assemblies"
  else
    echo "Spark libraries flagged as provided, app will not run in sbt"
  fi
fi

if [ $SCALA_MAJOR_VERSION == "2.10" ]; then SCALA_MINOR_VERSION="6"; fi
if [ $SCALA_MAJOR_VERSION == "2.11" ]; then SCALA_MINOR_VERSION="8"; fi

SCALA_VERSION="${SCALA_MAJOR_VERSION}.${SCALA_MINOR_VERSION}"

#
# Spark example code
#

function spark_example {
  cat << EOF1 > "$1"
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
EOF1
}


#
# Spark build.sbt
#

function spark_build {
  cat << EOF2 > "$1"
name := "$ONAME"

version := "1.0.0"

scalaVersion := "$SCALA_VERSION"

resolvers += "Hortonworks Repository" at "http://repo.hortonworks.com/content/repositories/releases/"
resolvers += "Hortonworks Jetty Maven Repository" at "http://repo.hortonworks.com/content/repositories/jetty-hadoop/"

libraryDependencies ++= Seq(
  // "com.betaocean" % "logoverhttp_${SCALA_MAJOR_VERSION}" % "1.0.0",
  "log4j"            % "log4j"           % "1.2.14",
  "org.apache.spark" % "spark-sql_${SCALA_MAJOR_VERSION}"  % "$SPARK_VERSION" $PROVIDED,
  "org.apache.spark" % "spark-hive_${SCALA_MAJOR_VERSION}" % "$SPARK_VERSION" $PROVIDED $HIVE_EXCLUDES
)
EOF2
}


#
# Scala example code
#

function scala_example {
  cat << EOF3 > "$1"
object $ONAME {

  def main(args: Array[String]) = {
    println(s"Hello Scala ${SCALA_VERSION}")
  }
}
EOF3
}


#
# Scala build.sbt
#

function scala_build {
  cat << EOF4 > "$1"
name := "$ONAME"

version := "1.0.0"

scalaVersion := "$SCALA_VERSION"

libraryDependencies ++= Seq(
  "log4j"            % "log4j"           % "1.2.14"
)
EOF4
}

#
# Scala example code
#

function java_example {
  cat << EOF5 > "$1"
public class $ONAME {

  public static void main(String[] args) {
    System.out.println("Hello Java");
  }
}
EOF5
}


#
# Scala build.sbt
#

function java_build {
  cat << EOF6 > "$1"
name := "$ONAME"

version := "1.0.0"

crossPaths := false // Do not append Scala versions to the generated artifacts

libraryDependencies ++= Seq(
  "log4j"            % "log4j"           % "1.2.14"
)
EOF6
}


#
# Create a suitable object name from the given project name
#

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

echo "Creating project \"$PNAME\" with main class \"$ONAME\""


#
# Create project
#

mkdir -p $PNAME
cd $PNAME

if [ $JAVA -eq 0 ]; then
  mkdir -p src/main/scala

  if [ $SPARK -eq 1 ]; then
    spark_example "src/main/scala/$ONAME.scala"
    spark_build "./build.sbt"
  else
    scala_example "src/main/scala/$ONAME.scala"
    scala_build "./build.sbt"
  fi
else
  mkdir -p src/main/java

  java_example "src/main/java/$ONAME.java"
  java_build "./build.sbt"
fi

#
# Create project folder and add sbt assembly
#

mkdir project
cat << EOF5 > project/plugins.sbt
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "$SBT_ASSEMBLY_VERSION")
EOF5

subl .
