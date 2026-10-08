-- 7a
CREATE DATABASE retail_sales;

ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

CREATE TABLE IF NOT EXISTS orders (
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

    RAISE NOTICE 'Customer ID: %, Total Sales: %',
        p_customer_id, v_total_sales;
END;
$$;

CALL get_customer_sales('C001');

-- 9a
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

    RAISE NOTICE 'Applied discount of % to region %',
        p_discount_rate, p_region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);

-- 10a
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

CALL get_sales_between(DATE '2024-01-01', DATE '2024-03-31');
