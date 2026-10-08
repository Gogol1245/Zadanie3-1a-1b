-- Active: 1790267907695@@127.0.0.1@5432@superstore
#1a
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

SELECT COUNT(*)
FROM high_value_customers;


#2b
CREATE OR REPLACE VIEW regional_monthly_sales AS
SELECT
    c.region,
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(o.sales) AS monthly_sales
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.region,
    DATE_TRUNC('month', o.order_date);

    SELECT region, month, monthly_sales
FROM regional_monthly_sales
WHERE region = 'West'
ORDER BY month;

#3a
CREATE OR REPLACE VIEW analyst_orders AS
SELECT
    order_id,
    customer_id,
    product_id,
    sales,
    quantity,
    discount
FROM orders;

#4a
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';

#5a
CREATE INDEX idx_orders_order_date
ON orders (order_date);

SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS monthly_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;

#6a
CREATE INDEX idx_orders_region_category
ON orders(customer_id, order_date);
SELECT c.customer_name,
    o.order_id,
    o.order_date,
    o.profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West'
AND o.order_date >= '2024-01-01';


#7a
CREATE DATABASE retail_sales;

CREATE TABLE orders (
    order_id    VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id  VARCHAR(20) NOT NULL,
    order_date  DATE        NOT NULL,
    region      VARCHAR(20) NOT NULL,
    category    VARCHAR(50) NOT NULL,
    ship_mode   VARCHAR(30) NOT NULL,
    sales       DECIMAL(10,2) NOT NULL,
    profit      DECIMAL(10,2) NOT NULL
);

ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Customer ID: %, Total Sales: %', p_customer_id, v_total_sales;
END;
$$;
CALL get_customer_sales('C001');

#9a
CREATE OR REPLACE PROCEDURE apply_regional_discount(
    p_region_name VARCHAR,
    p_discount_rate DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - p_discount_rate)
    WHERE region = p_region_name;

    RAISE NOTICE 'Applied discount of % to region %', p_discount_rate, p_region_name;
END;
$$;
CALL apply_regional_discount('West', 0.10);
CALL apply_regional_discount('West', 0.10);

#10a
CREATE OR REPLACE PROCEDURE get_sales_between(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN p_start_date AND p_end_date;

    RAISE NOTICE 'Start date: %, End date: %, Total sales: %',
        p_start_date, p_end_date, v_total_sales;
END;
$$;
CALL get_sales_between('2024-01-01', '2024-03-31');