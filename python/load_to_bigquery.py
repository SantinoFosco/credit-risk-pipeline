from google.cloud import bigquery
client = bigquery.Client(project="credit-risk-analytics-506721")

table_id = "credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data"

job_config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV,
    skip_leading_rows=1,
    autodetect=False,
    write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
)

with open("../data/raw/credit_data_sample.csv", "rb") as source_file:
    load_job = client.load_table_from_file(
        source_file,
        table_id,
        job_config=job_config,
    )

load_job.result()
print("Carga completada.")