CREATE DATABASE Ecommerce;
USE Ecommerce;

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    signup_date DATE,
    city VARCHAR(100),
    state VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    category_id INT,
    price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status VARCHAR(50),
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_item_id INT,
    return_date DATE,
    refund_amount DECIMAL(10,2),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
);

SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM returns;

SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM returns;

-- Question 1: Total Revenue and Total Profit - Which Product Category has most sales?
SELECT 
    SUM(oi.unit_price * oi.quantity) AS total_revenue,
    SUM((oi.unit_price - p.cost_price) * oi.quantity) AS total_profit,
    ROUND(
        SUM((oi.unit_price - p.cost_price) * oi.quantity) 
        / SUM(oi.unit_price * oi.quantity) * 100, 2
    ) AS profit_margin_percent
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- Question 2: Revenue by Category - Which Product Category generated the maximum revenue?
SELECT 
    c.category_name,
    SUM(oi.unit_price * oi.quantity) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Question 3: Order Status - What proportion of orders are successfully completed versus stuck, cancelled, or otherwise problematic?
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Question 4: Most Popular Payment Method - Which Payment Method do customers prefer the most?
SELECT 
    payment_method,
    COUNT(*) AS times_used,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY payment_method
ORDER BY times_used DESC;

-- Question 5: Top 5 Products by Revenue
SELECT 
    p.product_name,
    SUM(oi.unit_price * oi.quantity) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.unit_price * oi.quantity) DESC) AS revenue_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_rank
LIMIT 5;

-- Question 6: Top 3 Products per Catergory
SELECT category_name, product_name, total_revenue, rank_in_category
FROM (
    SELECT 
        c.category_name,
        p.product_name,
        SUM(oi.unit_price * oi.quantity) AS total_revenue,
        RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(oi.unit_price * oi.quantity) DESC) AS rank_in_category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name, p.product_name
) ranked
WHERE rank_in_category <= 3;

-- Question 7: Rank Customers by Total Lifetime Spend
SELECT 
    cu.name,
    SUM(oi.unit_price * oi.quantity) AS lifetime_spend,
    RANK() OVER (ORDER BY SUM(oi.unit_price * oi.quantity) DESC) AS spend_rank
FROM customers cu
JOIN orders o ON cu.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY cu.name
ORDER BY spend_rank
LIMIT 10;

-- Question 8: Month over Month Revenue Growth by Signup Cohort
WITH cohort_revenue AS (
    SELECT 
        DATE_FORMAT(cu.signup_date, '%Y-%m') AS signup_month,
        SUM(oi.unit_price * oi.quantity) AS total_revenue
    FROM customers cu
    JOIN orders o ON cu.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY signup_month
)
SELECT 
    signup_month, total_revenue,
    LAG(total_revenue) OVER (ORDER BY signup_month) AS previous_cohort_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY signup_month)) 
        / LAG(total_revenue) OVER (ORDER BY signup_month) * 100, 2
    ) AS growth_percent
FROM cohort_revenue
ORDER BY signup_month;

-- Question 9: Return Rate by Category
SELECT 
    c.category_name,
    COUNT(DISTINCT oi.order_item_id) AS total_items_sold,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(COUNT(DISTINCT r.return_id) * 100.0 / COUNT(DISTINCT oi.order_item_id), 2) AS return_rate_percent
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY c.category_name
ORDER BY return_rate_percent DESC;

-- Question 10: Profit Lost to Returns 
SELECT 
    c.category_name,
    SUM(oi.unit_price * oi.quantity) AS gross_revenue,
    SUM(r.refund_amount) AS total_refunded,
    ROUND(SUM(r.refund_amount) * 100.0 / SUM(oi.unit_price * oi.quantity), 2) AS revenue_lost_percent
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY c.category_name
ORDER BY revenue_lost_percent DESC;