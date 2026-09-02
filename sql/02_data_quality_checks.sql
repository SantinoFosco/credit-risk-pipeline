--- Validacion de duplicados en person_id
SELECT person_id, COUNT(*) AS cantidad
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY person_id
HAVING COUNT(*) > 1;

--- Validacion de valores nulos en columnas importantes
SELECT COUNTIF(person_id IS NULL) as person_id_null, COUNTIF(monthly_income IS NULL) as monthly_income_null, COUNTIF(total_debt IS NULL) as total_debt_null
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`;

--- Validacion de calidad de datos en columnas numericas y categoricas
SELECT COUNTIF(credit_utilization < 0 OR credit_utilization > 1) as invalid_credit_utilization,
COUNTIF(age < 18 OR age > 90) as invalid_age,
COUNTIF(monthly_income < 0) as invalid_monthly_income,
COUNTIF(num_credit_lines < 0) as invalid_num_credit_lines,
COUNTIF(default_probability < 0 OR default_probability > 1) as invalid_default_probability,
COUNTIF(late_payments_12m < 0 OR late_payments_12m > 12) as invalid_late_payments,
COUNTIF(region NOT IN ('CABA', 'GBA Norte', 'GBA Sur', 'GBA Oeste', 'Cordoba', 'Santa Fe', 'Mendoza', 'Tucuman')) AS invalid_region,
COUNTIF(risk_segment NOT IN ('Bajo', 'Medio', 'Alto', 'Muy Alto')) AS invalid_risk_segment
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`