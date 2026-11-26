-- Final model table: the application plus one row of history per applicant.
-- Every feat_* table is already one row per SK_ID_CURR, so these LEFT JOINs
-- cannot duplicate applicants. Applicants with no history get NULLs, which is
-- information in itself (thin-file customers), so keep them.
CREATE OR REPLACE TABLE model_table AS
SELECT
    a.*,
    -- Ratio features from the application itself
    a.AMT_CREDIT  / NULLIF(a.AMT_INCOME_TOTAL, 0) AS credit_to_income,
    a.AMT_ANNUITY / NULLIF(a.AMT_INCOME_TOTAL, 0) AS annuity_to_income,
    a.AMT_CREDIT  / NULLIF(a.AMT_GOODS_PRICE, 0)  AS credit_to_goods_price,
    -a.DAYS_BIRTH / 365.25                        AS age_years,
    -- 365243 is a placeholder (mostly pensioners), not a real value
    CASE WHEN a.DAYS_EMPLOYED = 365243 THEN 1 ELSE 0 END AS days_employed_anomaly,
    CASE WHEN a.DAYS_EMPLOYED = 365243 THEN NULL ELSE -a.DAYS_EMPLOYED / 365.25 END AS years_employed,
    b.* EXCLUDE (SK_ID_CURR),
    p.* EXCLUDE (SK_ID_CURR),
    i.* EXCLUDE (SK_ID_CURR)
FROM application_train a
LEFT JOIN feat_bureau       b USING (SK_ID_CURR)
LEFT JOIN feat_prev         p USING (SK_ID_CURR)
LEFT JOIN feat_installments i USING (SK_ID_CURR);
