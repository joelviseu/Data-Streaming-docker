# Data Streaming docker

## Overview

This project demonstrates a complete data streaming pipeline using Docker Compose, featuring:

- **Kafka** for streaming ingestion.
- **Spark** for ETL (reads from Kafka, writes Parquet to MinIO).
- **MinIO** for S3-compatible object storage.
- **Hive** as a metastore for S3 (MinIO).
- **Trino** for federated SQL querying.

## Architecture

```
Kafka --> Spark --> MinIO (Parquet) <-- Hive Metastore <-- Trino
```

## Folder Structure

- `.env` – Environment variables for all services/scripts.
- `e2e-pipeline.sh` – End-to-end orchestration script.
- `docker-compose.yml` – Multi-service orchestration.
- `spark/` – Scala ETL job and build script.
- `hive/conf/`, `spark/conf/`, `trino/etc/` – Configuration for each service.

## Quickstart

### 1. Prerequisites

- Docker and Docker Compose
- Java, Scala, and scalac (for Scala build)

### 2. Clone and Build

```bash
git clone https://github.com/joelviseu/Data-Streaming-docker.git
cd Data-Streaming-docker
```

### 3. Configure

Edit `.env` as required.

### 4. Build Spark Job

```bash
cd spark
bash build_scala_spark_job.sh
cd ..
```

### 5. Start All Services

```bash
docker-compose up -d
```

### 6. Run End-to-End Pipeline

```bash
bash e2e-pipeline.sh
```

### 7. Results

- The sample JSON is sent to Kafka.
- Spark reads from Kafka, writes Parquet to MinIO.
- Hive table is created over Parquet.
- Trino queries the table for results.

## Customization

- Edit `.env` to change topic names, credentials, etc.
- Replace the Spark Scala job with your own ETL logic.

## License

MIT
````I'm waiting for your approval to continue pushing the files to your repository.