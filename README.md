## mksbt
Helper to create Spark 1.6 and 2.x sbt projects

```bash
mksbt.sh --scala10 | --scala11 | --spark1 | --spark2 | --java [--provided] project-name
```

#### Spark projects using Spark SQL and Spark Hive

- Create a Spark 1.6 project (without provided it runs in sbt, else it creates a smaller assembly using HDP deployed jars)

	```bash
	mksbt.sh --spark1 [--provided] test-project 
	```

- Create a Spark 2.x project (without provided it runs in sbt, else it creates a smaller assembly using HDP deployed jars)

	```bash
	mksbt.sh --spark2 [--provided] test-project
	```

#### Simple Scala or Java

- Create a scala 10 project (without Spark)

	```bash
	mksbt.sh --scala10 test-project
	```

- Create a scala 11 project (without Spark)
	
	```bash
	mksbt.sh --scala11 test-project 
	```

- Create a Java project (without Spark)

	```bash
	mksbt.sh --java test-project
	```


**Notes:** 

- For Spark currently HDP 2.5.3 (default) and 2.5.0 (commented) are supported 
- The project folder will be named `test-project`, the main class normalized to `TestProject`
- The resulting hierarchy will be

	```text
	test-project/
	 +- build.sbt
	 +- project
	 |   +- plugins.sbt
	 +- src
	     +- main
	         +- scala
	             +- TestProject.scala
	```
