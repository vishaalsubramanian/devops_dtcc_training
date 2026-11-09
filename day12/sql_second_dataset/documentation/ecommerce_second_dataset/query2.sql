-- Query 2: Inspect the top 10 highest valued successfully delivered transaction

SELECT TOP (10)
    order_id, order_date, customer_id, product_name, city,
    quantity, gross_merchandise_value, discount_pct, net_merchandise_sales
FROM dbo.vw_ecommerce_approved_sales
WHERE net_merchandise_sales >= 15000
ORDER BY net_merchandise_sales DESC, order_id;
GO