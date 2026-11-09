-- Query 5: Calculate Monthly Revenue

SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS sales_month,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units_sold,
    SUM(gross_merchandise_value) AS gross_revenue,
    SUM(discount_amount) AS total_discounts,
    SUM(net_merchandise_sales) AS net_revenue
FROM dbo.vw_ecommerce_approved_sales
GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY sales_month;