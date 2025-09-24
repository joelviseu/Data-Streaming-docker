import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._

object KafkaToParquet {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder.appName("KafkaToParquet").getOrCreate()

    val schema = StructType(Seq(
      StructField("id", IntegerType, true),
      StructField("name", StringType, true),
      StructField("amount", DoubleType, true),
      StructField("ts", StringType, true)
    ))

    val kafkaDF = spark.read
      .format("kafka")
      .option("kafka.bootstrap.servers", sys.env("KAFKA_BROKER"))
      .option("subscribe", sys.env("KAFKA_TOPIC"))
      .option("startingOffsets", "earliest")
      .load()

    val jsonDF = kafkaDF.select(
      from_json(col("value").cast("string"), schema).alias("data")
    ).select("data.*")

    jsonDF.write.mode("overwrite").parquet(sys.env("PARQUET_PATH"))

    spark.stop()
  }
}