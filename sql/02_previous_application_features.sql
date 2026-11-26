-- Earlier applications the applicant made to Home Credit.
-- Grain in: one row per previous application. Grain out: one row per SK_ID_CURR.
CREATE OR REPLACE TABLE feat_prev AS
SELECT
    SK_ID_CURR,
    COUNT(*)                                                                AS prev_app_count,
    SUM(CASE WHEN NAME_CONTRACT_STATUS = 'Approved' THEN 1 ELSE 0 END)      AS prev_approved_count,
    SUM(CASE WHEN NAME_CONTRACT_STATUS = 'Refused'  THEN 1 ELSE 0 END)      AS prev_refused_count,
    AVG(CASE WHEN NAME_CONTRACT_STATUS = 'Refused'  THEN 1.0 ELSE 0.0 END)  AS prev_refusal_rate,
    MAX(DAYS_DECISION)                                                      AS prev_days_since_latest_decision,
    AVG(AMT_CREDIT / NULLIF(AMT_APPLICATION, 0))                            AS prev_avg_credit_to_requested
FROM previous_application
GROUP BY SK_ID_CURR;
