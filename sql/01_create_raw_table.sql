CREATE TABLE `proyecto.dataset.tabla` (
    person_id INT64 NOT NULL,
    age INT64,
    region STRING,
    monthly_income NUMERIC,
    num_credit_lines INT64,
    total_debt NUMERIC,
    debt_to_income_ratio FLOAT64,
    credit_utilization FLOAT64,
    late_payments_12m INT64,
    account_open_date DATE,
    default_probability FLOAT64,
    risk_segment STRING,
    default_flag BOOL,
    ingestion_date DATE
)
PARTITION BY ingestion_date
CLUSTER BY risk_segment, region, default_flag;