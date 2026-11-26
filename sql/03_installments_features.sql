-- Repayment behaviour on earlier Home Credit loans.
-- DAYS_* are relative to the current application (negative = in the past).
-- days_late > 0 means the payment came after the due date.
-- Grain in: one row per instalment payment. Grain out: one row per SK_ID_CURR.
CREATE OR REPLACE TABLE feat_installments AS
WITH payments AS (
    SELECT
        SK_ID_CURR,
        DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT AS days_late,
        AMT_INSTALMENT - AMT_PAYMENT         AS amount_short
    FROM installments_payments
)
SELECT
    SK_ID_CURR,
    COUNT(*)                                               AS inst_payment_count,
    AVG(CASE WHEN days_late > 0 THEN 1.0 ELSE 0.0 END)     AS inst_late_share,
    MAX(days_late)                                         AS inst_max_days_late,
    AVG(GREATEST(days_late, 0))                            AS inst_avg_days_late,
    AVG(CASE WHEN amount_short > 0 THEN 1.0 ELSE 0.0 END)  AS inst_underpaid_share,
    SUM(GREATEST(amount_short, 0))                         AS inst_total_underpaid
FROM payments
GROUP BY SK_ID_CURR;
