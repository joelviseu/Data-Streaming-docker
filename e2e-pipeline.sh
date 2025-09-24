#!/bin/bash
set -e
source .env

# 1. Ensure MinIO bucket exists
echo "Creating bucket '$MINIO_BUCKET' in MinIO if not exists..."
docker-compose exec minio sh -c "
  mc alias set minio $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY && \
  mc mb -p minio/$MINIO_BUCKET || true
"

# 2. Create Kafka topic
echo "Creating Kafka topic: $KAFKA_TOPIC"
docker-compose exec kafka \
  kafka-topics.sh --create --topic $KAFKA_TOPIC --bootstrap-server $KAFKA_BROKER --replication-factor 1 --partitions 1 || true

# 3. Publish JSON message to Kafka
echo "Publishing message to Kafka..."
echo "$SAMPLE_JSON" | docker-compose exec -T kafka \
  kafka-console-producer.sh --broker-list $KAFKA_BROKER --topic $KAFKA_TOPIC

# 4. Submit Spark (Scala) job
echo "Submitting Spark job to read from Kafka and write Parquet to MinIO..."
docker cp spark/build/KafkaToParquet.jar spark:/tmp/
docker-compose exec spark spark-submit \
  --class KafkaToParquet \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0,org.apache.hadoop:hadoop-aws:3.3.2 \
  /tmp/KafkaToParquet.jar

# 5. Create Hive external table
echo "Creating Hive external table over Parquet files in MinIO..."
docker-compose exec hive-metastore bash -c "
  beeline -u 'jdbc:hive2://localhost:10000/default' -n $HIVE_USER -p $HIVE_PASSWORD -e \"
    CREATE EXTERNAL TABLE IF NOT EXISTS kitchensink_hive (
      id INT,
      name STRING,
      amount DOUBLE,
      ts STRING
    )
    STORED AS PARQUET
    LOCATION '$PARQUET_PATH';
  \"
"

# 6. Query data in Trino
echo "Querying Trino for data from Hive table (MinIO Parquet)..."
docker-compose exec trino trino \
  --server ${TRINO_HOST}:${TRINO_PORT} \
  --catalog ${TRINO_CATALOG} \
  --schema ${TRINO_SCHEMA} \
  --execute "SELECT * FROM kitchensink_hive;"

echo "End-to-end pipeline executed successfully!"