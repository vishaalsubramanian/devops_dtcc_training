-- View 1: remove confirmed exact duplicate CSV rows, normalize text,
-- parse dates and amounts safely, and FLAG conflicting order IDs / suspicious values.
-- Never delete the original raw data or silently choose between conflicting records.
CREATE OR ALTER VIEW dbo.vw_ecommerce_clean AS
WITH exact_dedup AS (
    SELECT DISTINCT * FROM dbo.ecommerce_raw
),
parsed AS (
    SELECT
        NULLIF(TRIM(CAST(order_id AS nvarchar(4000))), N'') AS order_id,
        COALESCE(
            TRY_CONVERT(date, NULLIF(TRIM(CAST(order_date AS nvarchar(4000))), N''), 23),  -- yyyy-mm-dd
            TRY_CONVERT(date, NULLIF(TRIM(CAST(order_date AS nvarchar(4000))), N''), 103), -- dd/mm/yyyy
            TRY_CONVERT(date, NULLIF(TRIM(CAST(order_date AS nvarchar(4000))), N''), 111)  -- yyyy/mm/dd
        ) AS order_date,
        NULLIF(TRIM(CAST(customer_id AS nvarchar(4000))), N'') AS customer_id,
        NULLIF(TRIM(CAST(product_id AS nvarchar(4000))), N'') AS product_id,
        NULLIF(TRIM(CAST(product_name AS nvarchar(4000))), N'') AS product_name,
        CASE UPPER(TRIM(CAST(category AS nvarchar(4000))))
            WHEN N'ACCESSORIES' THEN N'Accessories'
            ELSE NULLIF(TRIM(CAST(category AS nvarchar(4000))), N'')
        END AS category,
        CASE UPPER(TRIM(CAST(city AS nvarchar(4000))))
            WHEN N'BANGALORE' THEN N'Bengaluru'
            WHEN N'BENGALURU' THEN N'Bengaluru'
            WHEN N'CHENNAI' THEN N'Chennai'
            WHEN N'COIMBATORE' THEN N'Coimbatore'
            WHEN N'DELHI' THEN N'Delhi'
            WHEN N'HYDERABAD' THEN N'Hyderabad'
            WHEN N'MUMBAI' THEN N'Mumbai'
            ELSE NULLIF(TRIM(CAST(city AS nvarchar(4000))), N'')
        END AS city,
        NULLIF(TRIM(CAST(state AS nvarchar(4000))), N'') AS state,
        TRY_CONVERT(int, NULLIF(TRIM(CAST(quantity AS nvarchar(4000))), N'')) AS quantity,
        TRY_CONVERT(decimal(18,2), NULLIF(REPLACE(REPLACE(REPLACE(TRIM(CAST(unit_price AS nvarchar(4000))), N'₹', N''), N',', N''), N' ', N''), N'')) AS unit_price,
        TRY_CONVERT(decimal(9,2), NULLIF(TRIM(CAST(discount_pct AS nvarchar(4000))), N'')) AS discount_pct,
        TRY_CONVERT(decimal(18,2), NULLIF(REPLACE(REPLACE(TRIM(CAST(shipping_fee AS nvarchar(4000))), N',', N''), N' ', N''), N'')) AS shipping_fee,
        CASE UPPER(TRIM(CAST(payment_method AS nvarchar(4000))))
            WHEN N'UPI' THEN N'UPI'
            ELSE NULLIF(TRIM(CAST(payment_method AS nvarchar(4000))), N'')
        END AS payment_method,
        CASE UPPER(TRIM(CAST(order_status AS nvarchar(4000))))
            WHEN N'DELIVERED' THEN N'Delivered'
            WHEN N'CANCELLED' THEN N'Cancelled'
            WHEN N'RETURNED' THEN N'Returned'
            WHEN N'PLACED' THEN N'Placed'
            WHEN N'SHIPPED' THEN N'Shipped'
            ELSE NULLIF(TRIM(CAST(order_status AS nvarchar(4000))), N'')
        END AS order_status,
        NULLIF(TRIM(CAST(sales_channel AS nvarchar(4000))), N'') AS sales_channel,
        TRY_CONVERT(int, NULLIF(TRIM(CAST(customer_rating AS nvarchar(4000))), N'')) AS customer_rating
    FROM exact_dedup
),
with_price_baselines AS (
    SELECT p.*,
           PERCENTILE_CONT(0.5) WITHIN GROUP (
               ORDER BY CASE WHEN p.unit_price > 0 THEN p.unit_price ELSE NULL END
           ) OVER (PARTITION BY p.product_id) AS product_median_unit_price
    FROM parsed AS p
)
SELECT p.*,
       CASE WHEN p.unit_price > 5.0 * p.product_median_unit_price
            THEN 1 ELSE 0 END AS is_price_outlier_candidate,
       CASE WHEN p.quantity BETWEEN 1 AND 20
                  AND p.unit_price > 0
                  AND p.discount_pct BETWEEN 0 AND 100
                  AND p.unit_price <= 5.0 * p.product_median_unit_price
            THEN 1 ELSE 0 END AS is_amount_valid,
       CASE WHEN COUNT(*) OVER (PARTITION BY p.order_id) = 1
            THEN 1 ELSE 0 END AS is_unambiguous_order
FROM with_price_baselines AS p;
GO

-- View 2: completed merchandise sales only. Excludes duplicates with conflicting
-- order details, invalid/missing or extreme transaction amounts, bad dates, cancelled/returned/incomplete
-- orders, and the exceptional quantity=250 pending investigation.
-- Merchandise sales exclude shipping fees and taxes; neither is silently treated as zero.
CREATE OR ALTER VIEW dbo.vw_ecommerce_approved_sales AS
SELECT
    order_id, order_date, customer_id, product_id, product_name,
    category, city, state, quantity, unit_price, discount_pct,
    shipping_fee, payment_method, order_status, sales_channel, customer_rating,
    CAST(ROUND(quantity * unit_price, 2) AS decimal(18,2)) AS gross_merchandise_value,
    CAST(ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2) AS decimal(18,2)) AS net_merchandise_sales,
    CAST(ROUND(quantity * unit_price * (discount_pct / 100.0), 2) AS decimal(18,2)) AS discount_amount
FROM dbo.vw_ecommerce_clean
WHERE order_status = N'Delivered'
  AND is_amount_valid = 1
  AND is_unambiguous_order = 1
  AND order_date IS NOT NULL;
GO

-- Verify successful load / cleaning / approved sales:
SELECT COUNT(*) AS raw_rows FROM dbo.ecommerce_raw;
SELECT COUNT(*) AS deduplicated_rows FROM dbo.vw_ecommerce_clean;
SELECT COUNT(*) AS approved_delivered_sales FROM dbo.vw_ecommerce_approved_sales;
GO