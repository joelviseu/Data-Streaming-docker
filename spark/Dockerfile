FROM bitnami/spark:3.3.0

USER root
COPY conf/spark-defaults.conf /opt/bitnami/spark/conf/
COPY conf/log4j.properties /opt/bitnami/spark/conf/
COPY conf/jars/*.jar /opt/bitnami/spark/jars/
COPY spark_example_kafka_to_parquet.scala /tmp/
RUN scalac -classpath "/opt/bitnami/spark/jars/*" /tmp/spark_example_kafka_to_parquet.scala -d /tmp/ && \
    jar cf /tmp/spark_example_kafka_to_parquet.jar -C /tmp/ .