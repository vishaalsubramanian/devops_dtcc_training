-- Query 7: Compare Payment Methods by Revenue

WITH PaymentRevenue AS
(
    SELECT
        COALESCE(
            payment_method,
            'Not Specified'
        ) AS payment_method,
        COUNT(*) AS total_orders,
        SUM(net_merchandise_sales) AS total_revenue,
        AVG(net_merchandise_sales) AS average_order_value
    FROM dbo.vw_ecommerce_approved_sales
    GROUP BY
        COALESCE(
            payment_method,
            'Not Specified'
        )
)

SELECT
    payment_method,
    total_orders,
    total_revenue,
    ROUND(
        average_order_value, 2
    ) AS average_order_value,
    CAST(
        100.0 * total_revenue /
        NULLIF(SUM(total_revenue) OVER (), 0)
        AS DECIMAL(6,2)
    ) AS revenue_percentage
FROM PaymentRevenue
ORDER BY total_revenue DESC;