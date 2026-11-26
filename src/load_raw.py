"""Load the Kaggle CSVs from data/raw/ into a local DuckDB database.

Usage:
    python src/load_raw.py

DuckDB reads the CSVs directly and stores them in a single file, so later
queries run in seconds instead of re-reading 2.5 GB of CSV every time.
"""
import sys
import time

import duckdb

from config import DB_PATH, PROCESSED_DIR, RAW_DIR, RAW_TABLES


def main() -> None:
    missing = [f for f in RAW_TABLES.values() if not (RAW_DIR / f).exists()]
    if missing:
        print("Missing files in data/raw/:")
        for f in missing:
            print(f"  - {f}")
        print("\nDownload them with:\n  kaggle competitions download -c home-credit-default-risk -p data/raw")
        sys.exit(1)

    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB_PATH))

    print(f"Loading into {DB_PATH}\n")
    for table, filename in RAW_TABLES.items():
        start = time.time()
        path = (RAW_DIR / filename).as_posix()
        con.execute(
            f"CREATE OR REPLACE TABLE {table} AS "
            f"SELECT * FROM read_csv_auto('{path}', sample_size=-1)"
        )
        rows = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        cols = len(con.execute(f"DESCRIBE {table}").fetchall())
        print(f"  {table:<24} {rows:>12,} rows  {cols:>4} cols  ({time.time() - start:.1f}s)")

    con.close()
    print("\nDone. Next step: python src/build_features.py")


if __name__ == "__main__":
    main()
