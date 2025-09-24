#!/bin/bash
set -e

# ---- CONFIGURATION ----
KAFKA_CONTAINER=kafka
SPARK_CONTAINER=spark
HIVE_CONTAINER=hive-metastore
TRINO_CONTAINER=trino
MINIO_BUCKET=warehouse
KAFKA_TOPIC=kitchensink
PARQUET_PATH="s3a://$MINIO_BUCKET/kitchensink"
SAMPLE_JSON='{"id":1, "name":"Alice", "amount": 123.45, "ts":"2025-09-24T22:47:10Z"}'

# ---- 1. Ensure MinIO Bucket Exists ----
echo "Creating bucket '$MINIO_BUCKET' in MinIO if not exists..."
docker exec minio bash -c "
    mc alias set minio http://minio:9000 minio minio123 && \
    mc mb -p minio/$MINIO_BUCKET || true
"

# ---- 2. Create Kafka Topic ----
echo "Creating Kafka topic: $KAFKA_TOPIC"
docker exec $KAFKA_CONTAINER \
  kafka-topics.sh --create --topic $KAFKA_TOPIC --bootstrap-server $KAFKA_CONTAINER:9092 --replication-factor 1 --partitions 1 || true

# ---- 3. Publish JSON Message to Kafka ----
echo "Publishing message to Kafka..."
echo "$SAMPLE_JSON" | docker exec -i $KAFKA_CONTAINER \
  kafka-console-producer.sh --broker-list $KAFKA_CONTAINER:9092 --topic $KAFKA_TOPIC

# ---- 4. Run Spark Job to Read from Kafka and Store as Parquet on MinIO ----
echo "Running Spark job to consume from Kafka and write Parquet to MinIO..."
docker cp spark_example_kafka_to_parquet.py $SPARK_CONTAINER:/tmp/
docker exec $SPARK_CONTAINER spark-submit \
    --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0,org.apache.hadoop:hadoop-aws:3.3.2 \
    /tmp/spark_example_kafka_to_parquet.py

# ---- 5. Create Hive Table over Parquet Files in MinIO ----
echo "Creating Hive external table over Parquet files in MinIO..."
docker exec $HIVE_CONTAINER bash -c "
    beeline -u 'jdbc:hive2://localhost:10000/default' -n hive -p hive -e \"
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

# ---- 6. Query Data in Trino ----
echo "Querying Trino for data from Hive table (MiniO Parquet)..."
docker exec $TRINO_CONTAINER trino \
    --server trino:8080 \
    --catalog hive \
    --schema default \
    --execute "SELECT * FROM kitchensink_hive;"

echo "End-to-end test completed successfully!"