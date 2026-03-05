/* =========================================================
   Project: E-commerce Analysis – Views & Aggregations
   Author: Mohamed Khafagy
   Description:
   This script creates views and performs aggregations
   for the E-commerce project, enabling dashboard
   building and reporting of sales, payments, and gaps.
   ========================================================= */


/* =========================================================
   1. Create Fact Table View for Sales
   ========================================================= */

CREATE VIEW vw_FactSales AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_state,
    c.customer_city,
    oi.product_id,
    p.product_category_name,
    oi.price,
    oi.shipping_charges
FROM df_Orders o
JOIN df_Customers c ON o.customer_id = c.customer_id
JOIN df_OrderItems oi ON o.order_id = oi.order_id
JOIN df_Products p ON oi.product_id = p.product_id;



/* =========================================================
   2. Create Order Level View with Delivery Days
   ========================================================= */

CREATE VIEW vw_Order_Level AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_timestamp,
    o.order_estimated_delivery_date,
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_timestamp) AS delivery_days
FROM df_Orders o;



/* =========================================================
   3. Top 20 Orders by Total Sales
   ========================================================= */

SELECT TOP 20
    fs.order_id,
    SUM(fs.price) AS sales_price,
    SUM(fs.shipping_charges) AS shipping,
    SUM(fs.price) + SUM(fs.shipping_charges) AS total_sales,
    SUM(p.payment_value) AS total_payment
FROM vw_FactSales fs
LEFT JOIN df_Payments p
    ON fs.order_id = p.order_id
GROUP BY fs.order_id
ORDER BY total_sales DESC;



/* =========================================================
   4. Orders vs Payments Gap by Status
   ========================================================= */

WITH sales AS (
    SELECT 
        oi.order_id,
        SUM(oi.price + oi.shipping_charges) AS total_sales
    FROM df_OrderItems oi
    GROUP BY oi.order_id
),
payments AS (
    SELECT
        p.order_id,
        SUM(p.payment_value) AS total_payment,
        MAX(p.payment_installments) AS installments
    FROM df_Payments p
    GROUP BY p.order_id
)
SELECT 
    o.order_status,
    COUNT(*) AS orders_count,
    SUM(s.total_sales) AS sum_sales,
    SUM(ISNULL(p.total_payment,0)) AS sum_payments,
    SUM(s.total_sales - ISNULL(p.total_payment,0)) AS gap
FROM df_Orders o
JOIN sales s ON o.order_id = s.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY gap DESC;



/* =========================================================
   5. Category-wise Sales for Dashboard
   ========================================================= */

CREATE VIEW vw_Dashboard_CategorySales AS
WITH CatSales AS (
    SELECT 
        p.product_category_name,
        SUM(oi.price + oi.shipping_charges) AS total_sales
    FROM df_OrderItems oi
    JOIN df_Products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
),
Ranked AS (
    SELECT
        product_category_name,
        total_sales,
        DENSE_RANK() OVER (ORDER BY total_sales DESC) AS rnk
    FROM CatSales
)
SELECT
    CASE
        WHEN rnk <= 10 THEN product_category_name
        ELSE 'Other'
    END AS category_group,
    SUM(total_sales) AS total_sales
FROM Ranked
GROUP BY
    CASE
        WHEN rnk <= 10 THEN product_category_name
        ELSE 'Other'
    END;