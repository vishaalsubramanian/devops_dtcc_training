-- Query 4: Above Average orders

SELECT TOP (10)
    a.order_id, a.category, a.product_name,
    a.net_merchandise_sales AS order_net_sales_inr,
    CAST((
        SELECT AVG(b.net_merchandise_sales)
        FROM dbo.vw_ecommerce_approved_sales AS b
        WHERE b.category = a.category
    ) AS decimal(18,2)) AS category_average_inr
FROM dbo.vw_ecommerce_approved_sales AS a
WHERE a.net_merchandise_sales > (
    SELECT AVG(b.net_merchandise_sales)
    FROM dbo.vw_ecommerce_approved_sales AS b
    WHERE b.category = a.category
)
ORDER BY a.net_merchandise_sales DESC, a.order_id;
GO