# Credit Risk Analytics Pipeline

Proyecto de portfolio orientado a un puesto de **Data Analyst** en el sector de
riesgo crediticio / credit bureaus. Simula el ciclo completo de vida del dato
en ese tipo de negocio: **ingesta → transformación → orquestación → análisis/reporte**,
usando **Python, SQL (BigQuery) y Cloud Composer (Airflow)**.

## Contexto / motivación

Las empresas de riesgo crediticio centralizan información financiera de
personas y empresas (uso de tarjetas de crédito, préstamos, atrasos de pago,
cheques rechazados) para generar reportes y scores de riesgo crediticio que
venden a bancos y financieras. Este proyecto reproduce, a escala reducida, el
tipo de pipeline analítico que sostiene ese negocio.

## Dataset

Los datos reales de comportamiento crediticio son privados y sensibles, así
que este proyecto usa un **dataset sintético generado a medida**
(`python/generate_synthetic_data.py`), con variables típicas de comportamiento
crediticio (ingresos, líneas de crédito, ratio deuda/ingreso, atrasos de pago,
utilización de crédito) y una probabilidad de default calculada con una
función logística — el mismo enfoque conceptual que usan los modelos de
scoring reales.

El generador escribe en chunks y **escala de miles a decenas de millones de
filas** sin cambios de diseño, lo cual permite diseñar las tablas de BigQuery
pensando en particionado y clustering desde el principio, no como un parche
posterior — algo relevante para empresas que manejan bases de decenas de
millones de registros.

Diccionario de columnas:

| Columna | Descripción |
|---|---|
| `person_id` | Identificador único de la persona |
| `age` | Edad |
| `region` | Región geográfica |
| `monthly_income` | Ingreso mensual estimado |
| `num_credit_lines` | Cantidad de líneas de crédito abiertas |
| `total_debt` | Deuda total actual |
| `debt_to_income_ratio` | Ratio deuda/ingreso |
| `credit_utilization` | % de utilización del crédito disponible |
| `late_payments_12m` | Cantidad de atrasos de pago en los últimos 12 meses |
| `account_open_date` | Fecha de apertura de la cuenta más antigua |
| `default_probability` | Probabilidad de default calculada (score) |
| `risk_segment` | Segmento de riesgo derivado (Bajo/Medio/Alto/Muy Alto) |
| `default_flag` | 1 si la persona entró en default, 0 si no |
| `ingestion_date` | Fecha de ingesta simulada (usada para particionado) |

## Estructura del repo

```
credit-risk-pipeline/
├── data/
│   ├── raw/            # CSVs generados (no versionados salvo una muestra chica)
│   └── processed/       # Salidas intermedias/locales, si aplica
├── sql/                 # DDL y queries de transformación/análisis en BigQuery
├── python/               # Scripts de generación de datos y carga a BigQuery
├── dags/                 # DAG de Cloud Composer / Airflow
├── notebooks/             # Exploración y validación de datos
├── dashboards/            # Notas/links del dashboard en Looker Studio
└── README.md
```

## Arquitectura (resumen)

1. **Generación/ingesta**: `generate_synthetic_data.py` genera el dataset y lo
   deja en `data/raw/` (localmente) o en un bucket de Cloud Storage.
2. **Carga a BigQuery**: `python/load_to_bigquery.py` carga el CSV a una tabla
   raw, particionada por `ingestion_date` y clusterizada por `risk_segment`.
3. **Transformación (SQL)**: queries en `sql/` limpian, validan calidad de datos
   y generan tablas analíticas (segmentación, tendencias, KPIs).
4. **Orquestación**: un DAG de Airflow en `dags/` encadena estos pasos y agrega
   validaciones de calidad (nulos, duplicados, rangos esperados).
5. **Consumo**: dashboard en Looker Studio conectado directo a BigQuery.

## Estado del proyecto

- [x] Generador de dataset sintético
- [ ] Script de carga a BigQuery
- [ ] DDL de tablas (raw + analítica)
- [ ] Queries de transformación/análisis
- [ ] DAG de Cloud Composer
- [ ] Dashboard en Looker Studio

## Cómo correrlo (local)

\`\`\`bash
cd python
python generate_synthetic_data.py --rows 2000000 --out ../data/raw/credit_data.csv
\`\`\`
