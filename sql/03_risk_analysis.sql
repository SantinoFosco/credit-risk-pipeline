--- Porcentaje de cartera por segmento de riesgo
SELECT
    risk_segment,
    COUNT(*) AS amount,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`) * 100, 2) AS percentage_by_segment,
    ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS default_rate_by_segment
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY risk_segment;

--- Tasa de default global
SELECT ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS global_default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`;

--- Tasa de default por region
SELECT region, ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS region_default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY region
ORDER BY region_default_rate DESC;

--- Clientes con riesgo de caer en default
SELECT COUNTIF(late_payments_12m >= 3 AND default_flag = FALSE) AS high_risk_customers
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`;

--- Combinacion de variables con mas tasa de default
SELECT CASE 
WHEN late_payments_12m >= 3 AND debt_to_income_ratio > 0.43 THEN 'Very High Risk'
WHEN late_payments_12m >= 3 AND debt_to_income_ratio <= 0.43 THEN 'High Risk'
WHEN late_payments_12m < 3 AND debt_to_income_ratio > 0.43 THEN 'Medium Risk'
ELSE 'Low Risk' END AS risk_category,
ROUND(AVG(CAST(default_flag AS INT)) * 100, 2) AS default_rate
FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
GROUP BY risk_category
ORDER BY default_rate DESC