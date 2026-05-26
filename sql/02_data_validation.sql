/*	===========================================
	SuperStore Sales SQL Project
	Data Validation
	Author: Asiya Nizam
	Tool: PostgreSQL (pgAdmin)
	=========================================== */

/*
NOTE:
Highlight and run each query individually for the best readability of outputs.
*/

/*	===========================================
	1. Quick Sanity Check
	===========================================*/
	
SELECT	*
FROM orders
LIMIT 10;

/*	============================================
	2. Data Type Inspection
	============================================*/

SELECT	column_name,
		data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY data_type;

/*	===========================================
	3. Row Count Check
	===========================================*/
	
SELECT	COUNT(*) AS total_rows
FROM ORDERS;

/*	===========================================
	4. Duplicate Check (Row_id Level)
	===========================================*/

SELECT	row_id,
		COUNT(*) AS occurences
FROM orders
GROUP BY row_id
HAVING COUNT(*) > 1;

/*	===========================================
	5. Orders Spanning Multiple Rows
	   (expected — one order can have many products)
	===========================================*/

SELECT	order_id,
		COUNT(*) AS row_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT 10;

/*	============================================
	6. Missing Values Check (Data Quality)
	============================================*/

SELECT
	COUNT(*) FILTER(WHERE sales IS NULL) AS missing_sales,
	COUNT(*) FILTER(WHERE profit IS NULL) AS missing_profit,
	COUNT(*) FILTER(WHERE order_date IS NULL) AS missing_order_date,
	COUNT(*) FILTER(WHERE customer_name IS NULL) AS missing_customer
FROM orders;

/*	============================================
	7. Invalid Sales
	============================================*/

SELECT COUNT(*) AS negative_sales
FROM orders
WHERE sales < 0;

SELECT COUNT(*) AS zero_sales
FROM orders
WHERE sales = 0;

/*	============================================
	8. Invalid Quantity
	============================================*/

SELECT COUNT(*) AS invalid_quantity
FROM orders
WHERE quantity <= 0;

/*	============================================
	9. Discount Range Check
	============================================*/

SELECT COUNT(*) AS discount_out_of_range
FROM orders
WHERE discount < 0 OR discount > 1;

/*	============================================
	10. Date Range Check
	============================================*/

SELECT	MIN(order_date) AS earliest_order_date,
		MAX(order_date) AS latest_order_date
FROM orders;

/*	============================================
	11. Ship Date Before Order Date Check
	============================================*/

SELECT COUNT(*) AS ship_before_order
FROM orders
WHERE ship_date < order_date;

/*	============================================
	12. Future Order Date Check
	============================================*/

SELECT COUNT(*) AS future_order_dates
FROM orders
WHERE order_date > CURRENT_DATE;

/*	============================================
	13. Distinct Category Check
	============================================*/

SELECT DISTINCT ship_mode FROM orders ORDER BY ship_mode;
SELECT DISTINCT region FROM orders ORDER BY region;
SELECT DISTINCT country_region FROM orders ORDER BY country_region;
SELECT DISTINCT category FROM orders ORDER BY category;
SELECT DISTINCT sub_category FROM orders ORDER BY sub_category;

/*	============================================
	14. Business KPI Sanity Check
	============================================*/

SELECT	SUM(sales) AS total_sales,
		SUM(profit) AS total_profit,
		COUNT(DISTINCT order_id) AS unique_orders,
		COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;





















