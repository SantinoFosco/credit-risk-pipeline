# Credit Risk Analytics Pipeline

Proyecto de portfolio orientado a un puesto de **Data Analyst** en el sector de
riesgo crediticio / credit bureaus. Simula el ciclo completo de vida del dato
en ese tipo de negocio: **ingesta → validación de calidad → transformación →
orquestación → análisis/reporte**, usando **Python, SQL (BigQuery) y Cloud
Composer (Airflow)**.

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

Diccionario de columnas de `raw_credit_data`:

| Columna | Descripción |
|---|---|
| `person_id` | Identificador único de la persona |
| `age` | Edad |
| `region` | Región geográfica |
| `monthly_income` | Ingreso mensual estimado (`NUMERIC`, monto de dinero) |
| `num_credit_lines` | Cantidad de líneas de crédito abiertas |
| `total_debt` | Deuda total actual (`NUMERIC`, monto de dinero) |
| `debt_to_income_ratio` | Ratio deuda/ingreso (`FLOAT64`) |
| `credit_utilization` | % de utilización del crédito disponible, 0-1 (`FLOAT64`) |
| `late_payments_12m` | Cantidad de atrasos de pago en los últimos 12 meses |
| `account_open_date` | Fecha de apertura de la cuenta más antigua |
| `default_probability` | Probabilidad de default calculada (score), 0-1 (`FLOAT64`) |
| `risk_segment` | Segmento de riesgo derivado (Bajo/Medio/Alto/Muy Alto) |
| `default_flag` | `BOOL` — true si la persona entró en default |
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

## Infraestructura en GCP

- **Proyecto**: `credit-risk-analytics-506721`
- **Dataset de BigQuery**: `credit_risk_analytics` (región `southamerica-east1`, São Paulo)
- **Tabla raw**: `raw_credit_data` — particionada por `ingestion_date`, clusterizada por `risk_segment, region`

## Archivos SQL (`sql/`)

| Archivo | Contenido |
|---|---|
| `01_create_raw_table.sql` | DDL de la tabla `raw_credit_data` (esquema, particionado, clustering) |
| `02_data_quality_checks.sql` | Validaciones de calidad: duplicados en `person_id`, nulos en columnas críticas, valores fuera de rango o categorías inválidas |
| `03_risk_analysis.sql` | Queries exploratorias de análisis de negocio (perfil de cartera, segmentación, detección de riesgo temprano) |
| `04_create_analytical_tables.sql` | `CREATE OR REPLACE TABLE` — materializa el análisis en tablas persistentes para el dashboard |

## Tablas analíticas (capa de reporte)

Generadas por `04_create_analytical_tables.sql`, cada una pensada para responder
una pregunta de negocio específica:

| Tabla | Pregunta que responde |
|---|---|
| `risk_segment_data` | % de cartera y tasa de default por segmento de riesgo |
| `global_default_data` | Tasa de default global de toda la cartera |
| `region_default_data` | Tasa de default por región geográfica |
| `high_risk_customers_data` | Cantidad de clientes con atrasos altos (≥3 en 12 meses) que todavía no cayeron en default |
| `risk_category_data` | Tasa de default por combinación de ratio deuda/ingreso y atrasos de pago |

## Arquitectura (resumen)

1. **Generación/ingesta**: `generate_synthetic_data.py` genera el dataset y lo
   deja en `data/raw/` (localmente) o en un bucket de Cloud Storage.
2. **Carga a BigQuery**: `python/load_to_bigquery.py` carga el CSV a
   `raw_credit_data` mediante `google-cloud-bigquery` (`WRITE_TRUNCATE`,
   esquema explícito).
3. **Validación de calidad**: `02_data_quality_checks.sql` confirma que los
   datos cargados son confiables antes de analizarlos.
4. **Transformación y materialización (SQL)**: `03_risk_analysis.sql` explora
   preguntas de negocio; `04_create_analytical_tables.sql` las persiste como
   tablas listas para consumir.
5. **Orquestación**: un DAG de Airflow en `dags/` va a encadenar estos pasos
   automáticamente (carga → validación → materialización), con manejo de
   dependencias y errores. *(pendiente)*
6. **Consumo**: dashboard en Looker Studio conectado directo a las tablas
   analíticas. *(pendiente)*

## Estado del proyecto

- [x] Generador de dataset sintético
- [x] Script de carga a BigQuery
- [x] DDL de tabla raw (particionada + clusterizada)
- [x] Validaciones de calidad de datos
- [x] Queries de análisis de riesgo
- [x] Tablas analíticas materializadas (CTAS)
- [ ] DAG de Cloud Composer / Airflow
- [ ] Dashboard en Looker Studio

## Cómo correrlo (local)

```bash
# Crear y activar entorno virtual
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Generar el dataset
cd python
python generate_synthetic_data.py --rows 2000000 --out ../data/raw/credit_data.csv

# Cargar a BigQuery
python load_to_bigquery.py
```

Luego, ejecutar en orden los archivos de `sql/` (01 → 04) desde la consola de
BigQuery.