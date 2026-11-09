-- Query 1: identify duplicates, conflicting order IDs, invalid/missing numbers

SELECT
    (SELECT COUNT(*) FROM dbo.ecommerce_raw) AS raw_rows,
    COUNT(*) AS rows_after_exact_dedup,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    (SELECT COUNT(*) FROM dbo.ecommerce_raw) - COUNT(*) AS exact_duplicate_rows,
    (SELECT COUNT(*) FROM (
        SELECT order_id FROM dbo.vw_ecommerce_clean
        GROUP BY order_id HAVING COUNT(*) > 1
    ) AS conflicting) AS conflicting_order_ids,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_or_invalid_dates,
    SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE 0 END) AS bad_or_missing_quantities,
    SUM(CASE WHEN quantity > 20 THEN 1 ELSE 0 END) AS quantity_outlier_candidates,
    SUM(CASE WHEN is_price_outlier_candidate = 1 THEN 1 ELSE 0 END) AS price_outlier_candidates,
    SUM(CASE WHEN unit_price IS NULL OR unit_price <= 0 THEN 1 ELSE 0 END) AS bad_or_missing_unit_prices,
    SUM(CASE WHEN discount_pct IS NULL OR discount_pct NOT BETWEEN 0 AND 100 THEN 1 ELSE 0 END) AS bad_or_missing_discounts,
    SUM(CASE WHEN shipping_fee IS NULL THEN 1 ELSE 0 END) AS missing_shipping_fees,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_cities
FROM dbo.vw_ecommerce_clean;
GO