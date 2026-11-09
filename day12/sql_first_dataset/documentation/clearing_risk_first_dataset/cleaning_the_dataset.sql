-- 1. Create the deduplicated view using ROW_NUMBER()
CREATE VIEW clearing_risk_clean AS
WITH RankedTrades AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY trade_id ORDER BY trade_id) AS rn
    FROM clearing_risk_dataset
)
SELECT * 
FROM RankedTrades
WHERE rn = 1;
GO

-- 2. Count rows in both the raw table and the clean view
SELECT COUNT(*) AS raw_rows FROM clearing_risk_dataset;
SELECT COUNT(*) AS deduplicated_trades FROM clearing_risk_clean;
