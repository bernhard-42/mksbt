name := "TestProject"

version := "1.0.0"

scalaVersion := "2.11.8"

resolvers += "Hortonworks Repository" at "http://repo.hortonworks.com/content/repositories/releases/"
resolvers += "Hortonworks Jetty Maven Repository" at "http://repo.hortonworks.com/content/repositories/jetty-hadoop/"

libraryDependencies ++= Seq(
  // "com.betaocean" % "logoverhttp_2.11" % "1.0.0",
  "log4j"            % "log4j"           % "1.2.14",
  "org.apache.spark" % "spark-sql_2.11"  % "2.0.0.2.5.3.0-37" ,
  "org.apache.spark" % "spark-hive_2.11" % "2.0.0.2.5.3.0-37"  excludeAll(ExclusionRule(organization = "org.spark-project.hive"))
)
