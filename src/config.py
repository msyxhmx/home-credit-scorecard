"""Project paths. Everything is relative to the repo root, so the scripts work
on Windows, macOS and Linux no matter which folder you run them from."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
SQL_DIR = ROOT / "sql"
FIGURES_DIR = ROOT / "reports" / "figures"

DB_PATH = PROCESSED_DIR / "home_credit.duckdb"
MODEL_TABLE_PATH = PROCESSED_DIR / "model_table.parquet"

# Raw CSVs expected in data/raw/ (table name -> file name)
RAW_TABLES = {
    "application_train": "application_train.csv",
    "application_test": "application_test.csv",
    "bureau": "bureau.csv",
    "bureau_balance": "bureau_balance.csv",
    "previous_application": "previous_application.csv",
    "installments_payments": "installments_payments.csv",
    "pos_cash_balance": "POS_CASH_balance.csv",
    "credit_card_balance": "credit_card_balance.csv",
}
