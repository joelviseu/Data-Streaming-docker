from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DoubleType

spark = SparkSession.builder \
    .appName("KafkaToParquet") \
    .getOrCreate()

# Define schema for the JSON payload
schema = StructType([
    StructField("id", IntegerType()),
    StructField("name", StringType()),
    StructField("amount", DoubleType()),
    StructField("ts", StringType())
])

# Read from Kafka
df_kafka = spark.read \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "kitchensink") \
    .option("startingOffsets", "earliest") \
    .load()

# Parse JSON and select fields
df = df_kafka.select(from_json(col("value").cast("string"), schema).alias("data")).select("data.*")

# Write as Parquet to MinIO (S3)
df.write.mode("overwrite").parquet("s3a://warehouse/kitchensink")

spark.stop()