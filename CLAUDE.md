# CLAUDE.md

Context for Claude Code sessions on this project. Read this first, then `ROADMAP.md`.

## About the project and how to work with me

This is a portfolio project for credit risk and data analytics roles. It is a credit risk scorecard on Kaggle's Home Credit Default Risk dataset, built the way a bank risk team would: raw relational data in SQL (DuckDB), features aggregated to one row per applicant, an interpretable logistic regression scorecard (WoE binning, points scaling), a LightGBM challenger, SHAP explainability, reason codes, a fairness check, cut-off analysis, and PSI monitoring. The full 6-week plan is in `ROADMAP.md`.

I am a recent applied data science graduate and proficient in Python. I want to learn by doing, so:

- Explain the reasoning behind each step, especially credit risk concepts (WoE/IV, Gini, KS, PSI, reject inference, calibration).
- Let me write some of the code myself when it is a good learning moment (for example the new SQL features), then review what I wrote. Do not silently generate everything.
- Ask me interview-style questions about the work now and then.

Environment: Windows, VS Code, project `.venv` created with `python -m venv .venv`, dependencies installed with `pip install -r requirements.txt`. I run plain Python scripts from the repo root. Keep all paths cross-platform with `pathlib` (see `src/config.py`).

Writing style: in the README and anything written in my voice, use full sentences. Do not use the "Label: text" colon style (for example "Key takeaway: ..."). Keep the README business-focused, meaning what decision the model supports and what errors cost, not just metrics.

Git: commit in small meaningful steps (for example "Add data overview notebook", "Add bureau_balance features") and push to `origin main`. Before every commit run `git status` and make sure no data files, `.duckdb`, `.parquet`, `.zip`, `kaggle.json` or `access_token` are staged. Tick the matching boxes in `ROADMAP.md` as steps are finished.

## Design decisions already made

- DuckDB is the local SQL engine (no server). Features are written in SQL first, Python second.
- Every history table is aggregated to one row per `SK_ID_CURR` before joining, to avoid join fan-out. `src/build_features.py` asserts that `model_table` has exactly one row per applicant and the same row count as `application_train`.
- `DAYS_EMPLOYED = 365243` is a placeholder (mostly pensioners). It is flagged in `days_employed_anomaly` and set to NULL in `years_employed`.
- Applicants with no bureau or previous-application history keep NULLs. Thin file is a signal, so they are not dropped.
- `bureau_balance`, `pos_cash_balance` and `credit_card_balance` are loaded but not used yet. They are the candidates for my own extra features.
- SQL files in `sql/` run in alphabetical order. A new feature source gets a new numbered file and a LEFT JOIN in `sql/99_model_table.sql`.

## Progress so far (Week 1)

Done:

- Repo created and pushed to GitHub (`msyxhmx/home-credit-scorecard`, branch `main`).
- Repo cloned locally on Windows, `.venv` created, requirements installed, VS Code Python and Jupyter extensions installed and the `.venv` interpreter selected.
- The full requirements set also installs and imports cleanly on Python 3.13 (DuckDB 2.0.1), checked in a cloud session.
- All source and SQL files reviewed. The pipeline has only been smoke-tested on synthetic data, not on the real Kaggle files.

In progress (next thing to do):

1. Accept the competition rules on Kaggle, create an API token (Kaggle Settings, API, Generate New Token) and save it to `%USERPROFILE%\.kaggle\access_token` (or put `kaggle.json` in that folder). Never inside the repo.
2. Run `kaggle competitions download -c home-credit-default-risk -p data/raw`, then `tar -xf data/raw/home-credit-default-risk.zip -C data/raw`.
3. Run `python src/load_raw.py` and check row counts against Kaggle. `application_train` should be 307,511 rows and 122 columns. Expected counts for the others: application_test 48,744; bureau 1,716,428; bureau_balance 27,299,925; previous_application 1,670,214; installments_payments 13,605,401; POS_CASH_balance 10,001,358; credit_card_balance 3,840,312.
4. Run `python src/build_features.py` and fix anything that breaks on real data (watch for column types inferred as VARCHAR).

Open question I was asked to think about: if the one-row-per-applicant check were removed and a feature table had duplicate `SK_ID_CURR` rows, what would the LEFT JOIN do to the model table, and why would that quietly damage the model?

## Review notes on the existing SQL (to act on)

- `sql/03_installments_features.sql`: `DAYS_ENTRY_PAYMENT` and `AMT_PAYMENT` are NULL for instalments with no recorded payment. `CASE WHEN days_late > 0 THEN 1.0 ELSE 0.0 END` currently counts those as on time, which hides the worst behaviour. A good first feature for me to write is a separate share or count of missed instalments, and to decide how late/underpaid shares should treat them.
- `previous_application` also uses the `365243` placeholder in `DAYS_FIRST_DRAWING`, `DAYS_FIRST_DUE`, `DAYS_LAST_DUE_1ST_VERSION`, `DAYS_LAST_DUE` and `DAYS_TERMINATION`. Not used yet, but it must be handled before any feature uses those columns.
- `CODE_GENDER` contains a few `XNA` values in `application_train`. Relevant for the Week 5 fairness check.

## Remaining Week 1 steps

1. Create `notebooks/01_data_overview.ipynb` (the `notebooks/` folder does not exist yet). Cover table row counts from DuckDB; the target rate (about 8% default, so the classes are imbalanced); top missing-value columns; the DAYS_EMPLOYED anomaly and its default rate; default rate by bins of EXT_SOURCE_1/2/3, age and credit_to_income; default rate with vs without bureau history. Use matplotlib/seaborn and save key charts to `reports/figures/`. End with a markdown cell where I write 3 to 5 findings myself.
2. Read `HomeCredit_columns_description.csv` and note 10 columns I expect to matter, before looking at results (a ROADMAP item).
3. Add at least 3 features of my own in SQL (for example from `bureau_balance`, `credit_card_balance`, or the missed-instalment fix above). I write the queries, Claude reviews them for grain, fan-out, NULL handling and leakage.
4. Commit after each step, tick the Week 1 boxes in `ROADMAP.md`, and update the README status line when Week 1 is complete.
