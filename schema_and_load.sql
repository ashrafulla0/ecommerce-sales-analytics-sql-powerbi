-- MySQL 8.0 setup for E-commerce Sales & Customer Analytics
-- Run once in MySQL Workbench, then run ecommerce_15_questions.sql
-- If LOAD DATA is blocked, use Workbench: right-click table > Table Data Import Wizard.

CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE customers (
  customer_id VARCHAR(10) PRIMARY KEY, segment VARCHAR(15), region VARCHAR(10),
  acquisition_channel VARCHAR(20), signup_date DATE);
CREATE TABLE products (
  product_id VARCHAR(10) PRIMARY KEY, category VARCHAR(20), product_name VARCHAR(40),
  unit_price DECIMAL(10,2), unit_cost DECIMAL(10,2));
CREATE TABLE orders (
  order_id VARCHAR(12) PRIMARY KEY, customer_id VARCHAR(10), product_id VARCHAR(10),
  order_date DATE, quantity INT, discount_pct INT, sales DECIMAL(12,2), profit DECIMAL(12,2),
  returned VARCHAR(3),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id));

-- Change the folder path below to where you saved the CSV files (use forward slashes)
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/ecommerce/customers.csv' INTO TABLE customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/ecommerce/products.csv' INTO TABLE products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/ecommerce/orders.csv' INTO TABLE orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- Row-count check: expect 3000 / 100 / 25000
SELECT 'customers' t, COUNT(*) n FROM customers UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders;
