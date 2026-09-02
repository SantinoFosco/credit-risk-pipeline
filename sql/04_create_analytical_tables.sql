--- Creacion de tabla analitica para datos por segmento de riesgo
CREATE OR REPLACE TABLE `credit-risk-analytics-506721.credit_risk_analytics.risk_segment_data` AS
SELECT
    risk_segment,
    COUNT(*) AS amount,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`) * 100, 2) AS percentage_by_segment,
    ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS default_rate_by_segment
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY risk_segment

---Creacion de tabla analitica para tasa de default global
CREATE OR REPLACE TABLE `credit-risk-analytics-506721.credit_risk_analytics.global_default_data` AS
SELECT ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS global_default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`

--- Creacion de tabla analitica para tasa de default por region
CREATE OR REPLACE TABLE `credit-risk-analytics-506721.credit_risk_analytics.region_default_data` AS
SELECT region, ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS region_default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY region

--- Creacion de tabla analitica para clientes con riesgo de caer en default
CREATE OR REPLACE TABLE `credit-risk-analytics-506721.credit_risk_analytics.high_risk_customers_data` AS
SELECT COUNTIF(late_payments_12m >= 3 AND default_flag = FALSE) AS high_risk_customers
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`

--- Creacion de tabla analitica para combinacion de variables con mas tasa de default
CREATE OR REPLACE TABLE `credit-risk-analytics-506721.credit_risk_analytics.risk_category_data` AS
SELECT CASE 
WHEN late_payments_12m >= 3 AND debt_to_income_ratio > 0.43 THEN 'Very High Risk'
WHEN late_payments_12m >= 3 AND debt_to_income_ratio <= 0.43 THEN 'High Risk'
WHEN late_payments_12m < 3 AND debt_to_income_ratio > 0.43 THEN 'Medium Risk'
ELSE 'Low Risk' END AS risk_category,
ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY risk_category