--- Validacion de duplicados en person_id
ASSERT(
    SELECT COUNT(*) = 0
    FROM (
        SELECT person_id FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        GROUP BY person_id
        HAVING COUNT(*) > 1
    )
) AS 'Se encontraron identificadores de personas duplicados';

--- Validacion de valores nulos en columnas importantes
ASSERT(
    SELECT COUNT(*) = 0
    FROM (
        SELECT person_id FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE person_id IS NULL 
    )
) AS 'Se encontraron valores nulos en la columna person_id';

ASSERT(
    SELECT COUNT(*) = 0
    FROM (
        SELECT monthly_income FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE monthly_income IS NULL 
    )
) AS 'Se encontraron valores nulos en la columna monthly_income';

ASSERT(
    SELECT COUNT(*) = 0
    FROM (
        SELECT total_debt FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE total_debt IS NULL 
    )
) AS 'Se encontraron valores nulos en la columna total_debt';

--- Validacion de calidad de datos en columnas numericas y categoricas
ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT credit_utilization FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE credit_utilization < 0 OR credit_utilization > 1
    )
) AS 'Se encontraron valores inválidos en la columna credit_utilization';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT age FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE age < 18 OR age > 90
    )
) AS 'Se encontraron valores inválidos en la columna age';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT monthly_income FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE monthly_income < 0
    )
) AS 'Se encontraron valores inválidos en la columna monthly_income';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT num_credit_lines FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE num_credit_lines < 0
    )
) AS 'Se encontraron valores inválidos en la columna num_credit_lines';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT default_probability FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE default_probability < 0 OR default_probability > 1
    )
) AS 'Se encontraron valores inválidos en la columna default_probability';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT late_payments_12m FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE late_payments_12m < 0 OR late_payments_12m > 12
    )
) AS 'Se encontraron valores inválidos en la columna late_payments_12m';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT region FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE region NOT IN ('CABA', 'GBA Norte', 'GBA Sur', 'GBA Oeste', 'Cordoba', 'Santa Fe', 'Mendoza', 'Tucuman')
    )
) AS 'Se encontraron valores inválidos en la columna region';

ASSERT(
    SELECT COUNT(*) = 0
    FROM(
        SELECT risk_segment FROM `credit-risk-analytics-506721.credit_risk_analytics.raw_credit_data`
        WHERE risk_segment NOT IN ('Bajo', 'Medio', 'Alto', 'Muy Alto')
    )
) AS 'Se encontraron valores inválidos en la columna risk_segment';