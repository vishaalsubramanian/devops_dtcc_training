-- Query 3: Ranking cities based on successful and verified sales.

SELECT
    city,
    COUNT(*) AS delivered_orders,
    SUM(quantity) AS units_sold,
    CAST(SUM(gross_merchandise_value) AS decimal(18,2)) AS gross_sales_inr,
    CAST(SUM(net_merchandise_sales) AS decimal(18,2)) AS net_sales_inr,
    CAST(AVG(net_merchandise_sales) AS decimal(18,2)) AS avg_order_value_inr
FROM dbo.vw_ecommerce_approved_sales
WHERE city IS NOT NULL
GROUP BY city
ORDER BY net_sales_inr DESC, city;
GO