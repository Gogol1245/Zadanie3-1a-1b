#1b
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(total_amount) AS total_daily_sales
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT sale_date, total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

#2b
WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT total_sales
FROM category_sales
WHERE product_category = 'Noodles';

#3b

WITH product_sales AS (
    SELECT
        product_category,
        product_name,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT product_category, total_product_sales, category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category, category_rank;


#4b
WITH customer_sales AS (
    SELECT
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_percentages AS (
    SELECT
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS revenue_percentage
    FROM customer_sales
)
SELECT
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM revenue_percentages
ORDER BY revenue DESC;

#5b
WITH ranked_transactions AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS row_num
    FROM flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM ranked_transactions
WHERE row_num = 1
ORDER BY customer_id ASC;

#6b
WITH RECURSIVE date_bounds AS (
    SELECT
        MIN(sale_date) AS first_date,
        MAX(sale_date) AS last_date
    FROM flourmills_sales
),
calendar AS (
    SELECT first_date AS sale_date, last_date
    FROM date_bounds

    UNION ALL

    SELECT sale_date + 1, last_date
    FROM calendar
    WHERE sale_date < last_date
)
SELECT COUNT(*)
FROM calendar;


#7b
WITH RECURSIVE monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sale_date)::date AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT
        next_month.rn,
        next_month.month,
        next_month.revenue,
        current_month.cumulative_revenue + next_month.revenue
    FROM cumulative_target AS current_month
    JOIN ordered_months AS next_month
        ON next_month.rn = current_month.rn + 1
    WHERE current_month.cumulative_revenue < 500000000
)
SELECT month, cumulative_revenue
FROM cumulative_target
WHERE cumulative_revenue >= 500000000
ORDER BY rn
LIMIT 1;