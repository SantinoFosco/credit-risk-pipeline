"""
generate_synthetic_data.py

Genera un dataset sintetico de comportamiento crediticio de personas,
pensado para simular (a escala reducida) el tipo de datos que maneja
una empresa de riesgo crediticio: informacion demografica + comportamiento
de pago + score de riesgo.

Diseñado para escalar: podes generar desde 10,000 hasta 60,000,000+ de
registros cambiando N_ROWS. El script escribe en chunks para no consumir
toda la RAM de golpe.

Uso:
    python generate_synthetic_data.py --rows 2000000 --out ../data/raw/credit_data.csv
"""

import argparse
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

REGIONS = ["CABA", "GBA Norte", "GBA Sur", "GBA Oeste", "Cordoba", "Santa Fe", "Mendoza", "Tucuman"]
CHUNK_SIZE = 200_000  # filas por lote escrito a disco


def generate_chunk(n, rng, start_id):
    """Genera un lote de n registros sinteticos de riesgo crediticio."""

    person_id = np.arange(start_id, start_id + n)

    # --- Variables demograficas base ---
    age = rng.normal(loc=40, scale=12, size=n).clip(18, 85).astype(int)

    # Ingreso mensual (ARS, en miles) correlacionado levemente con la edad
    base_income = rng.lognormal(mean=1.1, sigma=0.5, size=n) * 300
    income = (base_income + (age - 18) * 4).clip(150, 8000)

    region = rng.choice(REGIONS, size=n, p=[0.18, 0.16, 0.14, 0.12, 0.12, 0.1, 0.1, 0.08])

    # --- Variables de comportamiento crediticio ---
    num_credit_lines = rng.poisson(lam=2.2, size=n).clip(0, 12)
    total_debt = (rng.lognormal(mean=0.8, sigma=0.9, size=n) * (income * 0.15)).clip(0, None)

    # Ratio deuda/ingreso -- variable clave en riesgo crediticio
    debt_to_income = (total_debt / (income + 1)).clip(0, 5)

    credit_utilization = rng.beta(a=2, b=3, size=n)  # 0 a 1

    # Atrasos de pago en los ultimos 12 meses (mas probable si el ratio deuda/ingreso es alto)
    late_payment_rate = 0.05 + 0.35 * (debt_to_income / debt_to_income.max())
    late_payments_12m = rng.binomial(n=12, p=late_payment_rate.clip(0, 0.9))

    open_since_days = rng.integers(30, 365 * 15, size=n)
    account_open_date = [
        (datetime(2024, 1, 1) - timedelta(days=int(d))).date().isoformat()
        for d in open_since_days
    ]

    # --- Variable objetivo: probabilidad de default (score de riesgo) ---
    # Combinacion logistica de variables -> similar a como se construyen
    # los scores de riesgo crediticio reales.
    z = (
        -3.0
        + 2.2 * (debt_to_income / 2)
        + 1.8 * credit_utilization
        + 0.35 * late_payments_12m
        - 0.015 * (income / 100)
        - 0.01 * (age - 40) / 10
    )
    default_prob = 1 / (1 + np.exp(-z))
    default_flag = rng.binomial(n=1, p=default_prob.clip(0.01, 0.95))

    # Segmento de riesgo derivado del score (para reportes / dashboards)
    risk_segment = pd.cut(
        default_prob,
        bins=[-0.01, 0.15, 0.35, 0.6, 1.01],
        labels=["Bajo", "Medio", "Alto", "Muy Alto"],
    )

    ingestion_date = datetime(2026, 8, 25).date().isoformat()

    df = pd.DataFrame({
        "person_id": person_id,
        "age": age,
        "region": region,
        "monthly_income": income.round(2),
        "num_credit_lines": num_credit_lines,
        "total_debt": total_debt.round(2),
        "debt_to_income_ratio": debt_to_income.round(4),
        "credit_utilization": credit_utilization.round(4),
        "late_payments_12m": late_payments_12m,
        "account_open_date": account_open_date,
        "default_probability": default_prob.round(4),
        "risk_segment": risk_segment.astype(str),
        "default_flag": default_flag,
        "ingestion_date": ingestion_date,
    })
    return df


def generate_dataset(n_rows, out_path, seed):
    rng = np.random.default_rng(seed)
    
    rows_written = 0
    first_chunk = True
    start_id = 1

    while rows_written < n_rows:
        n = min(CHUNK_SIZE, n_rows - rows_written)
        chunk = generate_chunk(n, rng, start_id)
        chunk.to_csv(out_path, mode="w" if first_chunk else "a", header=first_chunk, index=False)
        first_chunk = False
        rows_written += n
        start_id += n
        print(f"Escritos {rows_written:,} / {n_rows:,} registros...")

    print(f"Listo. Dataset generado en: {out_path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rows", type=int, default=1_000_000, help="Cantidad total de registros a generar")
    parser.add_argument("--out", type=str, default="../data/raw/credit_data.csv", help="Path de salida")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    generate_dataset(args.rows, args.out, args.seed)


if __name__ == "__main__":
    main()
