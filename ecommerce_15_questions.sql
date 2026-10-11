-- E-commerce Sales & Customer Analytics | 15 business questions (MySQL 8.0)
-- Tables: customers, products, orders (one product line per order)

-- Q1: Total orders, revenue, profit and profit margin
SELECT COUNT(*) AS total_orders, ROUND(SUM(sales), 0) AS revenue, ROUND(SUM(profit), 0) AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 1) AS profit_margin_pct
FROM orders;

-- Q2: Monthly revenue and profit with month-over-month growth (window function)
WITH monthly AS (
  SELECT SUBSTR(order_date, 1, 7) AS order_month, ROUND(SUM(sales), 0) AS revenue, ROUND(SUM(profit), 0) AS profit
  FROM orders GROUP BY SUBSTR(order_date, 1, 7)
)
SELECT order_month, revenue, profit,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_month)) / LAG(revenue) OVER (ORDER BY order_month), 1) AS mom_growth_pct
FROM monthly ORDER BY order_month;

-- Q3: Which product categories generate the most revenue?
SELECT p.category, ROUND(SUM(o.sales), 0) AS revenue,
       ROUND(100.0 * SUM(o.sales) / SUM(SUM(o.sales)) OVER (), 1) AS revenue_share_pct
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category ORDER BY revenue DESC;

-- Q4: Which categories generate the most profit (and at what margin)?
SELECT p.category, ROUND(SUM(o.profit), 0) AS profit,
       ROUND(100.0 * SUM(o.profit) / SUM(o.sales), 1) AS margin_pct
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category ORDER BY profit DESC;

-- Q5: Which region has the highest revenue?
SELECT c.region, ROUND(SUM(o.sales), 0) AS revenue, ROUND(SUM(o.profit), 0) AS profit
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region ORDER BY revenue DESC;

-- Q6: Average order value by region
SELECT c.region, COUNT(*) AS orders, ROUND(AVG(o.sales), 0) AS avg_order_value
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region ORDER BY avg_order_value DESC;

-- Q7: Return rate by category
SELECT p.category, COUNT(*) AS orders,
       SUM(CASE WHEN o.returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
       ROUND(100.0 * SUM(CASE WHEN o.returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category ORDER BY return_rate_pct DESC;

-- Q8: Top 20 customers by revenue (DENSE_RANK window function)
WITH cr AS (
  SELECT c.customer_id, c.segment, c.acquisition_channel, ROUND(SUM(o.sales), 0) AS revenue, COUNT(*) AS orders
  FROM orders o JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.segment, c.acquisition_channel
)
SELECT DENSE_RANK() OVER (ORDER BY revenue DESC) AS rnk, customer_id, segment, acquisition_channel, orders, revenue
FROM cr ORDER BY rnk LIMIT 20;

-- Q9: How does discount level affect revenue and profit?
SELECT discount_pct, COUNT(*) AS orders, ROUND(SUM(sales), 0) AS revenue, ROUND(SUM(profit), 0) AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 1) AS margin_pct
FROM orders GROUP BY discount_pct ORDER BY discount_pct;

-- Q10: Which customer segments generate the most revenue?
SELECT c.segment, COUNT(DISTINCT c.customer_id) AS customers, ROUND(SUM(o.sales), 0) AS revenue,
       ROUND(100.0 * SUM(o.sales) / SUM(SUM(o.sales)) OVER (), 1) AS revenue_share_pct
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.segment ORDER BY revenue DESC;

-- Q11: Which acquisition channels generate the most revenue (and revenue per customer)?
WITH ch AS (
  SELECT c.acquisition_channel, COUNT(DISTINCT c.customer_id) AS customers, SUM(o.sales) AS revenue
  FROM orders o JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.acquisition_channel
)
SELECT acquisition_channel, customers, ROUND(revenue, 0) AS revenue, ROUND(revenue / customers, 0) AS revenue_per_customer
FROM ch ORDER BY revenue DESC;

-- Q12: Which categories have the highest quantity sold?
SELECT p.category, SUM(o.quantity) AS units_sold
FROM orders o JOIN products p ON o.product_id = p.product_id
GROUP BY p.category ORDER BY units_sold DESC;

-- Q13: Which months have the highest profit? (top 5)
SELECT SUBSTR(order_date, 1, 7) AS order_month, ROUND(SUM(profit), 0) AS profit
FROM orders GROUP BY SUBSTR(order_date, 1, 7) ORDER BY profit DESC LIMIT 5;

-- Q14: What is the overall return rate?
SELECT ROUND(100.0 * SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct FROM orders;

-- Q15: High-value customers (top 10% by revenue) and how many of their orders were returned (NTILE)
WITH cr AS (
  SELECT customer_id, SUM(sales) AS revenue,
         SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders, COUNT(*) AS orders
  FROM orders GROUP BY customer_id
), tiles AS (
  SELECT cr.*, NTILE(10) OVER (ORDER BY revenue DESC) AS decile FROM cr
)
SELECT CASE WHEN decile = 1 THEN 'Top 10% customers' ELSE 'Other customers' END AS customer_group,
       COUNT(*) AS customers, ROUND(SUM(revenue), 0) AS revenue,
       SUM(returned_orders) AS returned_orders,
       ROUND(100.0 * SUM(returned_orders) / SUM(orders), 1) AS return_rate_pct
FROM tiles GROUP BY CASE WHEN decile = 1 THEN 'Top 10% customers' ELSE 'Other customers' END;
