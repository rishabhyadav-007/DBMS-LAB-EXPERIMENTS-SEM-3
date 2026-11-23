-- EXPERIMENT 1
-- AIM: Design the relational tables for the Indian e-commerce ER model
-- described in the practical: Customer, Product, Order, OrderItem, Seller,
-- Category, Payment, Delivery and Address.
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS IndianEcommerceER;
USE IndianEcommerceER;

-- 1. Customer (strong entity)
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Multi-valued attribute: Customer.Phone_Numbers
CREATE TABLE CustomerPhone (
    customer_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id, phone_number),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- 2. Address (strong entity; belongs to a customer)
CREATE TABLE Address (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    flat_no VARCHAR(20),
    building_name VARCHAR(100),
    street_name VARCHAR(100),
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- 3. Seller (strong entity)
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Multi-valued attribute: Seller.Phone_Numbers
CREATE TABLE SellerPhone (
    seller_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (seller_id, phone_number),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE CASCADE
);

-- 4. Category (strong entity with recursive parent-category relationship)
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    hsn_code VARCHAR(30),
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL
);

-- 5. Product (superclass entity)
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Multi-valued attribute: Product.Image_URLs
CREATE TABLE ProductImage (
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    PRIMARY KEY (product_id, image_url),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- Product specialization: Electronics subtype
CREATE TABLE Electronics (
    product_id INT PRIMARY KEY,
    model_number VARCHAR(100),
    warranty_period VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- Product specialization: Clothing subtype
CREATE TABLE Clothing (
    product_id INT PRIMARY KEY,
    gender VARCHAR(30),
    material VARCHAR(60),
    size VARCHAR(30),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- 6. Order (strong entity)
CREATE TABLE CustomerOrder (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 7. OrderItem (weak entity; Item_Number is the partial key)
-- Composite primary key: (Order_ID, Item_Number)
CREATE TABLE OrderItem (
    order_id INT NOT NULL,
    item_number INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, item_number),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 8. Payment (strong entity; settles an order)
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (order_id) REFERENCES CustomerOrder(order_id)
);

-- 9. Delivery (strong entity; delivery for an order)
CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    tracking_no VARCHAR(100) NOT NULL UNIQUE,
    delivery_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES CustomerOrder(order_id)
);

-- End of Experiment 1 schema.
