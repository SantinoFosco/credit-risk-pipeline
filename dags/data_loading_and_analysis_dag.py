from airflow import DAG
from datetime import datetime

from scripts.generate_synthetic_data import generate_dataset
from scripts.load_to_bigquery import load_data_to_bigquery

from airflow.operators.python import PythonOperator

with DAG(
    dag_id="data_loading_and_analysis_dag",
    start_date=datetime(2026, 9, 8),
    schedule="@daily",
    catchup=False,
) as dag:
    generate_dataset_task = PythonOperator(
        task_id="generate_dataset",
        python_callable=generate_dataset,
        op_kwargs={"n_rows": 1000000, "out_path": "/opt/airflow/data/raw/credit_data.csv", "seed": 42},
    )

    load_data_task = PythonOperator(
        task_id="load_data_to_bigquery",
        python_callable=load_data_to_bigquery,
        op_kwargs={"path": "/opt/airflow/data/raw/credit_data.csv", "table_id": "credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data", "project_id": "credit-risk-analytics-506721"},
    )

    generate_dataset_task >> load_data_task