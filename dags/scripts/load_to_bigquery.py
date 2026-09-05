from google.cloud import bigquery
import argparse

def load_data_to_bigquery(path, table_id, project_id):

    client = bigquery.Client(project=project_id)

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=False,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

    with open(path, "rb") as source_file:
        load_job = client.load_table_from_file(
            source_file,
            table_id,
            job_config=job_config,
        )

    load_job.result()
    print("Carga completada.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", type=str, help="Ruta del archivo a cargar")
    parser.add_argument("--table_id", type=str, help="ID de la tabla en BigQuery")
    parser.add_argument("--project_id", type=str, help="ID del proyecto en Google Cloud")
    args = parser.parse_args()

    load_data_to_bigquery(args.path, args.table_id, args.project_id)


if __name__ == "__main__":
    main()