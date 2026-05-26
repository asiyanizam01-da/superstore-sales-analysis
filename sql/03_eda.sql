/*	==========================================================
	SuperStore Sales SQL Project
	EDA
	Author: Asiya Nizam
	Tool: pgAdmin (PostgreSQL)
	==========================================================*/

/*	==========================================================
	Create Filtered View
	Purpose: Restrict analysis to 2023 - 2025 business data
	==========================================================*/

CREATE OR REPLACE VIEW orders_2023_2025 AS
SELECT *
FROM orders
WHERE order_date < DATE '2026-01-01';

/*	==========================================================
	Filtered Dataset Check
	==========================================================*/
	
SELECT *
FROM orders_2023_2025
LIMIT 10;

/*	==========================================================
	Business KPI (Total Sales & Profit)
	==========================================================*/

SELECT
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(
		(SUM(profit)/SUM(sales)) * 100,
		2
	) AS profit_margin_pct,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers
FROM orders_2023_2025;

/*	===========================================================
	Yearly Sales Trend
	===========================================================*/

WITH yearly_sales_trend AS (

	SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		ROUND(SUM(sales),2) AS yearly_sales,
		ROUND(SUM(profit),2) AS yearly_profit
	FROM orders_2023_2025
	GROUP BY year
	
)

SELECT	year,
		yearly_sales,
		yearly_profit,
		LAG(yearly_sales) OVER(ORDER BY year) AS previous_year_sales,
		ROUND(
				(
					yearly_sales - 
					LAG(yearly_sales) OVER(ORDER BY year)
				) * 100
				/
				LAG(yearly_sales) OVER(ORDER BY year),
				2
		) AS sales_growth_pct
FROM yearly_sales_trend
ORDER BY year;

/*	==============================================================
	Monthly Sales Trend
	==============================================================*/

WITH monthly_sales_trend AS (

	SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		TO_CHAR(order_date, 'Mon') AS month_name,
		DATE_TRUNC('Month', order_date) AS month_date,
		ROUND(SUM(sales),2) AS monthly_revenue
	FROM orders_2023_2025
	GROUP BY
		year,
		month_name,
		month_date
		
)

SELECT
	year,
	month_name,
	month_date,
	monthly_revenue,
	LAG(monthly_revenue) OVER(ORDER BY month_date) AS previous_month_revenue,
	ROUND(
			(
				monthly_revenue -
				LAG(monthly_revenue)
				OVER(ORDER BY month_date)
			) * 100
			/
			LAG(monthly_revenue)
			OVER(ORDER BY month_date),
			2
		) AS sales_growth_pct
FROM monthly_sales_trend
ORDER BY
	month_date;

/*	===============================================================
	Sales By Region
	===============================================================*/

SELECT
	region,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(
		(SUM(profit)/SUM(sales))*100
	,2) AS profit_margin_pct,
	ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM orders_2023_2025
GROUP BY region
ORDER BY total_sales DESC;

/*	================================================================
	Top 10 States by Sales in Each Country
	================================================================*/

WITH states_ranked AS (

	SELECT
		country_region,
		state_province,
		COUNT(DISTINCT order_id) AS total_orders,
		ROUND(SUM(sales),2) AS total_sales,
		ROUND(SUM(profit),2) AS total_profit,
		DENSE_RANK() OVER(PARTITION BY country_region ORDER BY SUM(sales) DESC) AS rank
	FROM orders_2023_2025
	GROUP BY
		country_region,
		state_province
		
)

SELECT *
FROM states_ranked
WHERE rank <= 10
ORDER BY
	country_region,
	rank;

/*	===================================================================
	Sales by Category
	===================================================================*/

SELECT
	category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(
		(SUM(profit)/SUM(sales))*100
	,2) AS profit_margin_pct
FROM orders_2023_2025
GROUP BY category
ORDER BY total_sales DESC;

/*	====================================================================
	Sales Performance by Subcategory within each Category
	(Using subquery instead of CTE)
	====================================================================*/

SELECT *
FROM
	(
		SELECT
			category,
			sub_category,
			ROUND(SUM(sales),2) AS total_sales,
			ROUND(SUM(profit),2) AS total_profit,
			DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(sales) DESC) AS rank
		FROM orders_2023_2025
		GROUP BY
			category,
			sub_category
	) AS subcategory_ranked
ORDER BY
	category,
	rank;


/*	=====================================================================
	Top 10 Customers by Sales
	=====================================================================*/

SELECT
	customer_name,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM orders_2023_2025
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

/*	======================================================================
	Sales by Customer Segment
	======================================================================*/

SELECT
	segment,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(
		(SUM(profit)/SUM(sales)) * 100,
		2
	) AS profit_margin_pct,
	ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM orders_2023_2025
GROUP BY segment
ORDER BY total_sales DESC;

/*	======================================================================
	Sales by Shipmode
	======================================================================*/

SELECT
	ship_mode,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(
		AVG(ship_date - order_date)::NUMERIC,
		1
	) AS avg_days_to_ship
FROM orders_2023_2025
GROUP BY ship_mode
ORDER BY total_sales DESC;

/*	======================================================================
	Impact of Discount on Profitability
	======================================================================*/

SELECT
	CASE
		WHEN discount = 0 THEN '0% - No Discount'
		WHEN discount <= 0.1 THEN '1 - 10%'
		WHEN discount <= 0.2 THEN '11 - 20%'
		WHEN discount <= 0.3 THEN '21 - 30%'
		WHEN discount <= 0.4 THEN '31 - 40%'
		WHEN discount <= 0.5 THEN '41 - 50%'
		ELSE 'Above 50%'
	END AS discount_band,
	MIN(discount) AS sort_order,
	COUNT(*) AS total_rows,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(AVG(profit),2) AS average_profit
FROM orders_2023_2025
GROUP BY discount_band
ORDER BY sort_order;
	

	
	
	
	



















