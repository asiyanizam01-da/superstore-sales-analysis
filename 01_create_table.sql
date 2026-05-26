/*	======================================
	SuperStore Sales SQL Project
	Orders Table Creation
	Author: Asiya Nizam
	Tool: postgreSQL(pgAdmin)
	======================================*/

CREATE TABLE orders (
	row_id INT,
	order_id VARCHAR(50),
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(50),
	customer_id VARCHAR(50),
	customer_name VARCHAR(100),
	segment VARCHAR(50),
	country_region VARCHAR(100),
	city VARCHAR(100),
	state_province VARCHAR(100),
	postal_code VARCHAR(20),
	region VARCHAR(50),
	product_id VARCHAR(50),
	category VARCHAR(50),
	sub_category VARCHAR(50),
	product_name TEXT,
	sales NUMERIC(10,2),
	quantity INT,
	discount NUMERIC(5,2),
	profit NUMERIC(10,2)
);