"""Run every SQL file in sql/ in order, then export the final model table.

Usage:
    python src/build_features.py

Each SQL file creates one table. Files run in alphabetical order, so the
number prefix (01_, 02_, ...) controls the order. To add a new feature
source, add a new numbered file and join it in the final file.
"""
import time

import duckdb

from config import DB_PATH, MODEL_TABLE_PATH, SQL_DIR


def main() -> None:
    con = duckdb.connect(str(DB_PATH))

    for sql_file in sorted(SQL_DIR.glob("*.sql")):
        start = time.time()
        con.execute(sql_file.read_text(encoding="utf-8"))
        print(f"  ran {sql_file.name:<36} ({time.time() - start:.1f}s)")

    # Sanity checks: the model table must have exactly one row per applicant
    n_rows, n_ids = con.execute(
        "SELECT COUNT(*), COUNT(DISTINCT SK_ID_CURR) FROM model_table"
    ).fetchone()
    n_apps = con.execute("SELECT COUNT(*) FROM application_train").fetchone()[0]
    assert n_rows == n_ids == n_apps, (
        f"Row count problem: model_table={n_rows}, distinct ids={n_ids}, "
        f"application_train={n_apps}. A join is duplicating or dropping rows."
    )

    n_cols = len(con.execute("DESCRIBE model_table").fetchall())
    con.execute(f"COPY model_table TO '{MODEL_TABLE_PATH.as_posix()}' (FORMAT PARQUET)")
    con.close()

    print(f"\nmodel_table: {n_rows:,} rows x {n_cols} columns (one row per applicant, check passed)")
    print(f"Saved to {MODEL_TABLE_PATH}")


if __name__ == "__main__":
    main()
