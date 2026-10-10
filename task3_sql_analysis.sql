
-- Task 3: SQL for Data Analysis
-- Database: SQLite

PRAGMA foreign_keys = ON;

-- 1. Create tables
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT,
    email TEXT
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price REAL NOT NULL
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. Insert sample customers
INSERT INTO customers VALUES
(1, 'Ananya', 'Kochi', 'ananya@example.com'),
(2, 'Rahul', 'Kollam', 'rahul@example.com'),
(3, 'Meera', 'Trivandrum', 'meera@example.com'),
(4, 'Arjun', 'Kochi', 'arjun@example.com'),
(5, 'Diya', 'Kozhikode', NULL),
(6, 'Nikhil', 'Kollam', 'nikhil@example.com');

-- 3. Insert sample products
INSERT INTO products VALUES
(1, 'Mouse', 'Electronics', 799),
(2, 'Keyboard', 'Electronics', 1299),
(3, 'Bottle', 'Home', 299),
(4, 'Notebook', 'Stationery', 199),
(5, 'Headphones', 'Electronics', 2499),
(6, 'Lamp', 'Home', 999);

-- 4. Insert sample orders
INSERT INTO orders VALUES
(101, 1, '2026-09-01', 'Delivered'),
(102, 2, '2026-09-03', 'Delivered'),
(103, 1, '2026-09-10', 'Delivered'),
(104, 3, '2026-09-12', 'Cancelled'),
(105, 4, '2026-09-15', 'Delivered'),
(106, 5, '2026-09-18', 'Processing'),
(107, 2, '2026-09-20', 'Delivered');

-- 5. Insert order items
INSERT INTO order_items VALUES
(1, 101, 1, 2, 799),
(2, 101, 4, 3, 199),
(3, 102, 2, 1, 1299),
(4, 102, 3, 2, 299),
(5, 103, 5, 1, 2499),
(6, 104, 6, 1, 999),
(7, 105, 2, 1, 1299),
(8, 106, 6, 2, 999),
(9, 107, 1, 1, 799);

-- 6. SELECT and ORDER BY
SELECT * FROM customers
ORDER BY customer_name;

-- 7. WHERE
SELECT product_name, price
FROM products
WHERE price > 500
ORDER BY price DESC;

-- 8. GROUP BY, SUM and AVG
SELECT p.category,
       SUM(oi.quantity * oi.unit_price) AS total_revenue,
       AVG(oi.unit_price) AS average_price
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 9. INNER JOIN
SELECT o.order_id, c.customer_name, o.status
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;

-- 10. LEFT JOIN
SELECT c.customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 11. Subquery
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 12. Customer revenue
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC;

-- 13. Create a view
CREATE VIEW customer_revenue AS
SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(
           CASE WHEN o.status = 'Delivered'
           THEN oi.quantity * oi.unit_price
           ELSE 0 END
       ), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name;

-- 14. Query the view
SELECT * FROM customer_revenue
ORDER BY total_revenue DESC;

-- 15. Handle NULL values
SELECT customer_name,
       COALESCE(email, 'Email not provided') AS email
FROM customers;

-- 16. Create an index
CREATE INDEX idx_orders_customer
ON orders(customer_id);

-- 17. Average revenue per purchasing customer
SELECT AVG(customer_total) AS average_revenue_per_customer
FROM (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.unit_price) AS customer_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
) AS totals;
