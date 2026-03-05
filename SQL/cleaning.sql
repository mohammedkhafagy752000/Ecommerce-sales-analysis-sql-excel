/* =========================================================
   Project: E-commerce Data Cleaning
   Author: Mohamed Khafagy
   Description:
   This script performs data cleaning and validation
   for the e-commerce dataset before analysis.
   ========================================================= */


/* =========================================================
   1. Detect Duplicate Products
   ========================================================= */

-- Check duplicate product_id values
SELECT product_id, COUNT(*) AS duplicate_count
FROM df_Products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Check whether duplicated rows contain inconsistent values
SELECT 
    product_id,
    COUNT(DISTINCT product_category_name) AS category_variations,
    COUNT(DISTINCT product_weight_g) AS weight_variations,
    COUNT(DISTINCT product_length_cm) AS length_variations,
    COUNT(DISTINCT product_height_cm) AS height_variations,
    COUNT(DISTINCT product_width_cm) AS width_variations
FROM df_Products
GROUP BY product_id
HAVING COUNT(*) > 1;



/* =========================================================
   2. Remove Duplicate Products
   ========================================================= */

WITH DuplicateCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY product_id
               ORDER BY product_id
           ) AS row_num
    FROM df_Products
)
DELETE FROM DuplicateCTE
WHERE row_num > 1;



/* =========================================================
   3. Check Table Sizes
   ========================================================= */

SELECT COUNT(*) AS TotalRows FROM df_Products;
SELECT COUNT(*) AS TotalRows FROM df_Customers;
SELECT COUNT(*) AS TotalRows FROM df_Orders;
SELECT COUNT(*) AS TotalRows FROM df_OrderItems;
SELECT COUNT(*) AS TotalRows FROM df_Payments;



/* =========================================================
   4. Check Data Types in Orders Table
   ========================================================= */

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'df_Orders';



/* =========================================================
   5. Validate Date Columns Before Conversion
   ========================================================= */

SELECT 
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_timestamp,
    order_estimated_delivery_date
FROM df_Orders
WHERE TRY_CAST(order_purchase_timestamp AS DATETIME) IS NULL
   OR TRY_CAST(order_approved_at AS DATETIME) IS NULL
   OR TRY_CAST(order_delivered_timestamp AS DATETIME) IS NULL
   OR TRY_CAST(order_estimated_delivery_date AS DATE) IS NULL;



/* =========================================================
   6. Convert Columns to Date Type
   ========================================================= */

ALTER TABLE df_Orders
ALTER COLUMN order_purchase_timestamp DATE;

ALTER TABLE df_Orders
ALTER COLUMN order_approved_at DATE;

ALTER TABLE df_Orders
ALTER COLUMN order_delivered_timestamp DATE;

ALTER TABLE df_Orders
ALTER COLUMN order_estimated_delivery_date DATE;



/* =========================================================
   7. Validate Order Process Logic
   ========================================================= */

SELECT 
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_timestamp,
    order_estimated_delivery_date
FROM df_Orders
WHERE order_approved_at < order_purchase_timestamp
   OR order_delivered_timestamp < order_approved_at
   OR order_estimated_delivery_date < order_purchase_timestamp;



/* =========================================================
   8. Check Missing Values
   ========================================================= */

SELECT 
COUNT(*) AS total_rows,

SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_order_status,
SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_date,
SUM(CASE WHEN order_delivered_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date,
SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_estimated_delivery,
SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approval_date

FROM df_orders;



/* =========================================================
   9. Detect Invalid Default Dates
   ========================================================= */

UPDATE df_Orders
SET order_delivered_timestamp = NULL
WHERE order_delivered_timestamp = '1900-01-01';

UPDATE df_Orders
SET order_approved_at = NULL
WHERE order_approved_at = '1900-01-01';

UPDATE df_Orders
SET order_estimated_delivery_date = NULL
WHERE order_estimated_delivery_date = '1900-01-01';



/* =========================================================
   10. Fix Logical Delivery Errors
   ========================================================= */

-- Check cases where delivery occurred before approval
SELECT *
FROM df_Orders
WHERE order_delivered_timestamp < order_approved_at;


-- Calculate average delivery time
SELECT 
AVG(DATEDIFF(DAY, order_approved_at, order_delivered_timestamp)) 
AS avg_days_to_deliver
FROM df_Orders
WHERE order_delivered_timestamp >= order_approved_at;


-- Correct invalid delivery dates using average delivery time
UPDATE df_Orders
SET order_delivered_timestamp = DATEADD(DAY, 5, order_approved_at)
WHERE order_delivered_timestamp < order_approved_at;



/* =========================================================
   11. Validate Payments Table
   ========================================================= */

SELECT p.order_id
FROM df_Payments p
LEFT JOIN df_Orders o 
ON p.order_id = o.order_id
WHERE o.order_id IS NULL;



ALTER TABLE df_Payments
ALTER COLUMN payment_value FLOAT(10);


SELECT *
FROM df_Payments
WHERE payment_value < 0;



/* =========================================================
   12. Validate OrderItems Table
   ========================================================= */

SELECT *
FROM df_OrderItems
WHERE price < 0 OR shipping_charges < 0;


ALTER TABLE df_OrderItems
ALTER COLUMN price FLOAT(10);

ALTER TABLE df_OrderItems
ALTER COLUMN shipping_charges FLOAT(10);



/* =========================================================
   13. Validate Products Table
   ========================================================= */

ALTER TABLE df_Products
ALTER COLUMN product_weight_g FLOAT(10);

ALTER TABLE df_Products
ALTER COLUMN product_length_cm FLOAT(10);

ALTER TABLE df_Products
ALTER COLUMN product_height_cm FLOAT(10);

ALTER TABLE df_Products
ALTER COLUMN product_width_cm FLOAT(10);


SELECT *
FROM df_Products
WHERE product_weight_g <= 0
   OR product_height_cm <= 0
   OR product_length_cm <= 0
   OR product_width_cm <= 0;



/* =========================================================
   14. Replace Zero Product Weight Using Category Average
   ========================================================= */

UPDATE p
SET product_weight_g = c.avg_weight
FROM df_Products p
JOIN (
    SELECT 
        product_category_name,
        AVG(NULLIF(product_weight_g,0)) AS avg_weight
    FROM df_Products
    WHERE product_length_cm > 0
      AND product_height_cm > 0
      AND product_width_cm > 0
    GROUP BY product_category_name
) c
ON p.product_category_name = c.product_category_name
WHERE p.product_weight_g = 0
  AND p.product_length_cm > 0
  AND p.product_height_cm > 0
  AND p.product_width_cm > 0;



/* =========================================================
   15. Final Validation
   ========================================================= */

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM df_OrderItems;
