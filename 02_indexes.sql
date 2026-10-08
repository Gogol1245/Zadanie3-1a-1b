-- 4a
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
ON orders (customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';

-- 5a
CREATE INDEX IF NOT EXISTS idx_orders_order_date
ON orders (order_date);

SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS monthly_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;

-- 6a
CREATE INDEX IF NOT EXISTS idx_orders_customer_order_date
ON orders (customer_id, order_date);

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.profit
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.region = 'West'
  AND o.order_date >= DATE '2024-01-01';
