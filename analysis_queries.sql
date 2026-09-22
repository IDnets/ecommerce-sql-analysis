-- 1. Monthly Sales Performance & Revenue Aggregation
SELECT 
    DATE_TRUNC('month', order_date) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY 1
ORDER BY order_month DESC;

-- 2. Top 5 Customers by Revenue (Customer Lifetime Value)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_purchases,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC
LIMIT 5;

-- 3. Product Category Ranking by Region using Window Functions
WITH CategorySales AS (
    SELECT 
        c.region,
        p.category_name,
        SUM(oi.quantity * oi.unit_price) AS category_revenue,
        DENSE_RANK() OVER (PARTITION BY c.region ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rank_in_region
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.region, p.category_name
)
SELECT region, category_name, category_revenue
FROM CategorySales
WHERE rank_in_region <= 3;
