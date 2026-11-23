from Unnormalized Form (UNF) to Third Normal Form (3NF) and Boyce– Codd Normal Form
Use NormalizationDB;
Create a single flat table that stores all sales-related information with repeating groups and
CREATE TABLE IF NOT EXISTS Sales_UNF (
order_id INT,
order_date DATE,
customer_id INT,
customer_name VARCHAR(100),
customer_city VARCHAR(100),
city_state VARCHAR(100),
product_id INT,
product_name VARCHAR(100),
category VARCHAR(50),
unit_price DECIMAL(10,2),
quantity INT,
salesperson_id INT,
salesperson_name VARCHAR(100),
commission_pct DECIMAL(4,2)
);
--INSERT INTO Sales_UNF VALUES
(1001, '2026-01-15', 201, 'Riya Sharma', 'Pune', 'Maharashtra', 501, 'Laptop',
'Electronics', 55000.00, 2, 301, 'Arjun Mehta', 5.00),
(1001, '2026-01-15', 201, 'Riya Sharma', 'Pune', 'Maharashtra', 502, 'Mouse',
'Accessories', 800.00, 3, 301, 'Arjun Mehta', 5.00),
(1002, '2026-02-10', 202, 'Vikram Patel', 'Ahmedabad', 'Gujarat', 501, 'Laptop',
'Electronics', 55000.00, 1, 302, 'Sneha Iyer', 4.50),
(1003, '2026-02-20', 201, 'Riya Sharma', 'Pune', 'Maharashtra', 503, 'Keyboard',
'Accessories', 1500.00, 5, 301, 'Arjun Mehta', 5.00),
(1004, '2026-03-05', 203, 'Neha Kulkarni', 'Nagpur', 'Maharashtra', 504, 'Monitor',
'Electronics', 18000.00, 2, 303, 'Karan Desai', 6.00),
(1005, '2026-03-18', 204, 'Amit Joshi', 'Surat', 'Gujarat', 502, 'Mouse',
'Accessories', 800.00, 10,302, 'Sneha Iyer', 4.50),
(1006, '2026-04-01', 202, 'Vikram Patel', 'Ahmedabad', 'Gujarat', 505, 'Headphones',
'Accessories', 2500.00, 4, 302, 'Sneha Iyer', 4.50),
(1007, '2026-04-12', 205, 'Priya Nair', 'Kochi', 'Kerala', 501, 'Laptop', 'Electronics',
(1008, '2026-05-08', 203, 'Neha Kulkarni', 'Nagpur', 'Maharashtra', 503, 'Keyboard',
'Accessories', 1500.00, 3, 303, 'Karan Desai', 6.00),
(1009, '2026-05-25', 206, 'Rahul Verma', 'Jaipur', 'Rajasthan', 504, 'Monitor',
'Electronics', 18000.00, 1, 305, 'Pooja Singh', 4.00);
SELECT * FROM Sales_UNF;
Update anomaly: Changing customer city requires updating multiple rows.
primary key (order_id, product_id).
CREATE TABLE IF NOT EXISTS Sales_1NF (
order_id INT,
order_date DATE,
customer_id INT,
customer_name VARCHAR(100),
customer_city VARCHAR(100),
city_state VARCHAR(100),
product_id INT,
product_name VARCHAR(100),
category VARCHAR(50),
unit_price DECIMAL(10,2),
quantity INT,
salesperson_id INT,
salesperson_name VARCHAR(100),
commission_pct DECIMAL(4,2),
PRIMARY KEY (order_id, product_id)
);
INSERT INTO Sales_1NF SELECT * FROM Sales_UNF;
CREATE TABLE IF NOT EXISTS Orders_2NF (
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,
customer_name VARCHAR(100),
customer_city VARCHAR(100),
city_state VARCHAR(100),
salesperson_id INT,
salesperson_name VARCHAR(100),
commission_pct DECIMAL(4,2)
);
INSERT INTO Orders_2NF
SELECT DISTINCT order_id, order_date, customer_id, customer_name,
FROM Sales_1NF;
CREATE TABLE IF NOT EXISTS Products_2NF (
product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50),
unit_price DECIMAL(10,2)
);
INSERT INTO Products_2NF
SELECT DISTINCT product_id, product_name, category, unit_price
FROM Sales_1NF;
Table: OrderDetails_2NF — attributes dependent on the full key (order_id, product_id)
CREATE TABLE IF NOT EXISTS OrderDetails_2NF (
order_id INT,
product_id INT,
quantity INT,
PRIMARY KEY (order_id, product_id),
FOREIGN KEY (order_id) REFERENCES Orders_2NF(order_id),
FOREIGN KEY (product_id) REFERENCES Products_2NF(product_id)
);
INSERT INTO OrderDetails_2NF
SELECT order_id, product_id, quantity
FROM Sales_1NF;
CREATE TABLE IF NOT EXISTS Customers_3NF (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
customer_city VARCHAR(100)
);
INSERT INTO Customers_3NF
SELECT DISTINCT customer_id, customer_name, customer_city
FROM Orders_2NF;
CREATE TABLE IF NOT EXISTS Cities_3NF (
customer_city VARCHAR(100) PRIMARY KEY,
city_state VARCHAR(100)
);
INSERT INTO Cities_3NF
SELECT DISTINCT customer_city, city_state
FROM Orders_2NF;
CREATE TABLE IF NOT EXISTS Salespersons_3NF (
salesperson_id INT PRIMARY KEY,
salesperson_name VARCHAR(100),
commission_pct DECIMAL(4,2)
);
INSERT INTO Salespersons_3NF
SELECT DISTINCT salesperson_id, salesperson_name, commission_pct
FROM Orders_2NF;
CREATE TABLE IF NOT EXISTS Orders_3NF (
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,
salesperson_id INT,
FOREIGN KEY (customer_id) REFERENCES Customers_3NF(customer_id),
FOREIGN KEY (salesperson_id) REFERENCES Salespersons_3NF(salesperson_id)
);
INSERT INTO Orders_3NF
SELECT DISTINCT order_id, order_date, customer_id, salesperson_id
FROM Orders_2NF;
CREATE TABLE IF NOT EXISTS Products_3NF AS SELECT * FROM Products_2NF;
ALTER TABLE Products_3NF ADD PRIMARY KEY (product_id);
CREATE TABLE IF NOT EXISTS OrderDetails_3NF AS SELECT * FROM OrderDetails_2NF;
ALTER TABLE OrderDetails_3NF ADD PRIMARY KEY (order_id, product_id);
-- Reconstruct original data via natural joins
CREATE TABLE IF NOT EXISTS Sales_Reconstructed AS
SELECT
o.order_id,
o.order_date,
c.customer_id,
c.customer_name,
c.customer_city,
ct.city_state,
p.product_id,
p.product_name,
p.category,
p.unit_price,
od.quantity,
s.salesperson_id,
s.salesperson_name,
FROM OrderDetails_3NF od
JOIN Orders_3NF o ON od.order_id = o.order_id
JOIN Customers_3NF c ON o.customer_id = c.customer_id
JOIN Cities_3NF ct ON c.customer_city = ct.customer_city
JOIN Products_3NF p ON od.product_id = p.product_id
JOIN Salespersons_3NF s ON o.salesperson_id = s.salesperson_id;
--Verification query — compare row counts:
SELECT 'Original' AS source, COUNT(*) AS row_count FROM Sales_1NF
UNION ALL
SELECT 'Reconstructed', COUNT(*) FROM Sales_Reconstructed;
--Verification query — check for differences
-- Rows in original but not in reconstructed
(SELECT * FROM Sales_1NF)
EXCEPT
(SELECT * FROM Sales_Reconstructed);
-- Rows in reconstructed but not in original
(SELECT * FROM Sales_Reconstructed)
EXCEPT
(SELECT * FROM Sales_1NF);
Check that each of the original functional dependencies can be verified using only the attributes within
SELECT order_id
FROM Orders_3NF
GROUP BY order_id
HAVING COUNT(DISTINCT order_date)>1
OR COUNT(DISTINCT customer_id) > 1
OR COUNT(DISTINCT salesperson_id) > 1;
SELECT customer_id
FROM Customers_3NF
GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name)>1
OR COUNT(DISTINCT customer_city) > 1;
SELECT customer_city
FROM Cities_3NF
GROUP BY customer_city
HAVING COUNT(DISTINCT city_state)>1;
SELECT product_id
FROM Products_3NF
GROUP BY product_id
HAVING COUNT(DISTINCT product_name)>1
OR COUNT(DISTINCT category) > 1
OR COUNT(DISTINCT unit_price) > 1;
SELECT salesperson_id
FROM Salespersons_3NF
GROUP BY salesperson_id
HAVING COUNT(DISTINCT salesperson_name)>1
OR COUNT(DISTINCT commission_pct) > 1;
SELECT order_id, product_id
FROM OrderDetails_3NF
GROUP BY order_id, product_id
HAVING COUNT(DISTINCT quantity)>1;
with zero missing or spurious tuples.
update, and deletion anomalies. The lossless join property guarantees that no information is lost during
