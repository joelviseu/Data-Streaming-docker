import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._

object KafkaToParquet {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder
      .appName("KafkaToParquet")
      .getOrCreate()

    import spark.implicits._

    // Define the schema for the JSON payload
    val schema = StructType(Seq(
      StructField("id", IntegerType, true),
      StructField("name", StringType, true),
      StructField("amount", DoubleType, true),
      StructField("ts", StringType, true)
    ))

    // Read from Kafka
    val kafkaDF = spark.read
      .format("kafka")
      .option("kafka.bootstrap.servers", "kafka:9092")
      .option("subscribe", "kitchensink")
      .option("startingOffsets", "earliest")
      .load()

    // Parse the JSON and select fields
    val jsonDF = kafkaDF.select(
      from_json(col("value").cast("string"), schema).alias("data")
    ).select("data.*")

    // Write as Parquet to MinIO (S3)
    jsonDF.write.mode("overwrite").parquet("s3a://warehouse/kitchensink")

    spark.stop()
  }
}