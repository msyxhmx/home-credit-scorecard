-- Credit bureau history: loans the applicant has (or had) at OTHER lenders.
-- Grain in: one row per bureau loan. Grain out: one row per SK_ID_CURR.
CREATE OR REPLACE TABLE feat_bureau AS
SELECT
    SK_ID_CURR,
    COUNT(*)                                                    AS bureau_loan_count,
    SUM(CASE WHEN CREDIT_ACTIVE = 'Active' THEN 1 ELSE 0 END)   AS bureau_active_count,
    SUM(CASE WHEN CREDIT_ACTIVE = 'Bad debt' THEN 1 ELSE 0 END) AS bureau_bad_debt_count,
    MAX(DAYS_CREDIT)                                            AS bureau_days_since_latest_credit,
    MIN(DAYS_CREDIT)                                            AS bureau_days_since_first_credit,
    MAX(CREDIT_DAY_OVERDUE)                                     AS bureau_max_days_overdue,
    SUM(AMT_CREDIT_SUM)                                         AS bureau_total_credit,
    SUM(AMT_CREDIT_SUM_DEBT)                                    AS bureau_total_debt,
    SUM(AMT_CREDIT_SUM_OVERDUE)                                 AS bureau_total_overdue,
    SUM(AMT_CREDIT_SUM_DEBT) / NULLIF(SUM(AMT_CREDIT_SUM), 0)   AS bureau_debt_to_credit_ratio,
    SUM(CNT_CREDIT_PROLONG)                                     AS bureau_prolong_count
FROM bureau
GROUP BY SK_ID_CURR;
