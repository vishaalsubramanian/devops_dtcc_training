-- Query 6: Rank Products by Revenue
WITH ProductRevenue AS
(
    SELECT
        product_id,
        MAX(product_name) AS product_name,
        COUNT(*) AS total_orders,
        SUM(quantity) AS total_quantity_sold,
        SUM(net_merchandise_sales) AS total_revenue
    FROM dbo.vw_ecommerce_approved_sales
    GROUP BY product_id
)

SELECT
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS product_rank,
    product_id,
    product_name,
    total_orders,
    total_quantity_sold,
    total_revenue
FROM ProductRevenue
ORDER BY product_rank;