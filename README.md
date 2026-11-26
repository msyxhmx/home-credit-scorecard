# Home Credit Scorecard

An end-to-end credit risk project that predicts whether a loan applicant will have payment difficulties, built the way a bank's risk team would build it. The pipeline goes from raw relational data in SQL to an interpretable logistic regression scorecard, with a gradient boosting challenger, explainability and drift monitoring.

> Status: work in progress (Week 1 of 6). See [ROADMAP.md](ROADMAP.md).

## Business problem

Home Credit lends to people with little or no credit history. Every approval decision trades off two costs. Approving someone who defaults loses money, and rejecting someone who would have repaid loses a customer. The goal of this project is a model that ranks applicants by risk, can be explained to a credit committee and a regulator, and supports a clear approval cut-off.

## Data

[Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk/data) on Kaggle. It has about 307k labelled applications plus history tables from the credit bureau and from previous Home Credit loans.

| Table | Grain | Joins to |
|---|---|---|
| `application_train` | one row per current application (`SK_ID_CURR`) | target table |
| `bureau` | one row per past loan at other lenders | `SK_ID_CURR` |
| `bureau_balance` | monthly status of each bureau loan | `SK_ID_BUREAU` |
| `previous_application` | one row per earlier Home Credit application | `SK_ID_CURR` |
| `installments_payments` | one row per instalment paid on earlier loans | `SK_ID_PREV`, `SK_ID_CURR` |
| `POS_CASH_balance`, `credit_card_balance` | monthly snapshots of earlier loans | `SK_ID_PREV` |

The history tables are aggregated to one row per applicant in SQL (`sql/`) before they are joined to the application table, so the joins can never duplicate applicants.

## Project structure

```
home-credit-scorecard/
├── data/
│   ├── raw/            # Kaggle CSVs go here (not committed)
│   └── processed/      # DuckDB database + model table (not committed)
├── sql/                # feature engineering, one file per source table
├── src/
│   ├── config.py       # paths
│   ├── load_raw.py     # CSV -> DuckDB
│   └── build_features.py  # runs sql/ and exports the model table
├── notebooks/
│   └── 01_data_overview.ipynb
├── reports/figures/
├── ROADMAP.md
└── requirements.txt
```

## How to run

```bash
# 1. Create an environment and install dependencies
python -m venv .venv
.venv\Scripts\activate          # Windows  (macOS/Linux: source .venv/bin/activate)
pip install -r requirements.txt

# 2. Download the data (accept the competition rules on Kaggle first)
kaggle competitions download -c home-credit-default-risk -p data/raw
#    then unzip into data/raw/

# 3. Load into DuckDB and build features
python src/load_raw.py
python src/build_features.py

# 4. Explore
jupyter lab notebooks/01_data_overview.ipynb
```

## Results

Coming in Weeks 3 to 5. This section will hold the scorecard and challenger performance (AUC, Gini, KS), the approval rate versus bad rate trade-off, and the top risk drivers.
