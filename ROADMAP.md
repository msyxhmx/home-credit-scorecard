# Roadmap (6 weeks)

Plan for roughly 8 to 10 hours a week. Each week ends with something committed to GitHub, so the repo shows steady progress even before it is finished.

## Week 1. Data foundation and SQL features
- [x] Download the data, run `load_raw.py` and check that the row counts match Kaggle
- [ ] Read `HomeCredit_columns_description.csv` and note down 10 columns you think will matter, before looking at any results
- [ ] Run `build_features.py`, then read every SQL file and make sure you can explain each feature
- [ ] Work through `01_data_overview.ipynb` (target rate, missing values, data anomalies, first look at risk drivers)
- [ ] Add at least 3 features of your own to the SQL files, such as the share of bureau credit that is overdue or the number of refused applications in the last year
- [ ] Commit and push. Write 3 to 5 bullet points of findings in the notebook

**What you learn:** SQL aggregation across one-to-many tables, avoiding join fan-out, profiling messy real data.

## Week 2. Problem framing, split and baseline
- [ ] Write a short "problem definition" section in the README covering what a positive label means, who uses the model and what a wrong decision costs
- [ ] Make a stratified train / validation / test split and keep the test set untouched until Week 5
- [ ] Check for leakage. Any feature that would not be known on the application date has to go
- [ ] Build a baseline logistic regression on a few raw features and record AUC and Gini
- [ ] Start `src/preprocess.py` for missing values, the `DAYS_EMPLOYED` anomaly and ratio features

**What you learn:** problem framing, leakage, honest validation, baselines.

## Week 3. The scorecard
- [ ] Bin numeric features (quantile bins first, then merge bins until default rates are monotonic)
- [ ] Calculate Weight of Evidence and Information Value. Drop features with IV < 0.02 and look suspiciously at IV > 0.5
- [ ] Remove highly correlated features (check VIF or pairwise correlation)
- [ ] Fit logistic regression on the WoE features and check that every coefficient has a sensible sign
- [ ] Scale to points (for example, 600 points = 50:1 odds, 20 points to double the odds) and produce a scorecard table
- [ ] Optional: try the `optbinning` library and compare its bins with yours

**What you learn:** the method banks actually use and why regulators prefer it.

## Week 4. Challenger model and evaluation
- [ ] Train LightGBM on the full feature set using early stopping on the validation set
- [ ] Compare the scorecard and LightGBM on AUC, Gini, KS and lift / gains charts
- [ ] Check calibration (reliability curve, Brier score) and calibrate if needed
- [ ] Write up the trade-off honestly, setting how much accuracy LightGBM gains against what it costs in interpretability

**What you learn:** model comparison beyond a single metric, calibration.

## Week 5. Explainability, fairness and business decisions
- [ ] Use SHAP for global feature importance and for explaining individual applicants
- [ ] Create reason codes, the top 3 reasons an applicant was declined
- [ ] Compare approval and default rates across `CODE_GENDER` and age bands and discuss what you find
- [ ] Build a cut-off table showing approval rate, bad rate and expected loss at each score threshold, then recommend a cut-off
- [ ] Evaluate on the untouched test set once, and only once

**What you learn:** turning a model into a decision, responsible AI, communicating with non-technical stakeholders.

## Week 6. Monitoring and polish
- [ ] Calculate the Population Stability Index (PSI) for the score and the top features (for example, train vs test, or early vs late `DAYS_DECISION` cohorts)
- [ ] Write a short monitoring plan covering what to track, the thresholds and when to retrain
- [ ] Finish the README with the results table, 2 or 3 key charts and the business recommendation
- [ ] Clean the notebooks (restart and run all), move reusable code into `src/` and pin `requirements.txt`
- [ ] Prepare a 2-minute verbal walkthrough of the project for interviews

**What you learn:** the model lifecycle after deployment and presenting your work.

## Stretch ideas (after Week 6)
- Serve the scorecard with a small FastAPI endpoint or a Streamlit app
- Rebuild the SQL layer with dbt
- Reject inference, i.e. how to handle applicants who were never approved and so never have an outcome
