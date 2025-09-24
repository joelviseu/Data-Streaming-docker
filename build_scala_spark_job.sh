#!/bin/bash
set -e

# --- Configuration ---
SCALA_FILE=spark_example_kafka_to_parquet.scala
JAR_NAME=KafkaToParquet.jar
CLASS_NAME=KafkaToParquet

# --- Prepare build directory ---
mkdir -p build
cp $SCALA_FILE build/

cd build

# --- Download Spark and Hadoop AWS dependencies if not present ---
SPARK_VERSION=3.3.0
HADOOP_AWS_JAR=hadoop-aws-3.3.2.jar
AWS_SDK_JAR=aws-java-sdk-bundle-1.11.1026.jar

if [ ! -f $HADOOP_AWS_JAR ]; then
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.2/$HADOOP_AWS_JAR
fi

if [ ! -f $AWS_SDK_JAR ]; then
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.1026/$AWS_SDK_JAR
fi

# --- Compile Scala code ---
scalac -classpath "$HADOOP_AWS_JAR:$AWS_SDK_JAR:/opt/bitnami/spark/jars/*" $SCALA_FILE

# --- Package into a JAR ---
jar cf $JAR_NAME *.class

# --- Cleanup class files ---
rm -f *.class

echo "JAR built at $(pwd)/$JAR_NAME"

cd ..