-- 1a: Customers whose total sales exceed 2,000
CREATE OR REPLACE VIEW high_value_customers AS
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT COUNT(*) AS high_value_customer_count
FROM high_value_customers;

-- 2b: Monthly sales by customer region
CREATE OR REPLACE VIEW regional_monthly_sales AS
SELECT
    c.region,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.sales) AS monthly_sales
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date);

SELECT region, month, monthly_sales
FROM regional_monthly_sales
WHERE region = 'West'
ORDER BY month;

-- 3a: Expose order fields without profit
CREATE OR REPLACE VIEW analyst_orders AS
SELECT
    order_id,
    customer_id,
    product_id,
    sales,
    quantity,
    discount
FROM orders;

SELECT *
FROM analyst_orders;
