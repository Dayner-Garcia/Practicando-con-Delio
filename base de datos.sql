CREATE DATABASE [Store];
USE [Store];

CREATE TABLE [Categories] (
    categoryId INT PRIMARY KEY IDENTITY (1,1),
    categoryName VARCHAR(100) NOT NULL
);

CREATE TABLE [Products] (
    productId INT PRIMARY KEY IDENTITY (1,1),
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    categoryId INT
);

CREATE TABLE [Customers] (
    customerId INT PRIMARY KEY IDENTITY (1,1),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE [Orders] (
    orderId INT PRIMARY KEY IDENTITY (1,1),
    customerId INT,
    productId INT,
    quantity INT NOT NULL,
    orderDate DATE NOT NULL
);

ALTER TABLE [Products]
ADD CONSTRAINT FK_Products_Categories
FOREIGN KEY (categoryId) REFERENCES [Categories] (categoryId);

ALTER TABLE [Orders]
ADD CONSTRAINT FK_Orders_Products
FOREIGN KEY (productId) REFERENCES [Products] (productId);

ALTER TABLE [Orders]
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (customerId) REFERENCES [Customers] (customerId);

CREATE TRIGGER UpdateStock
ON [Orders]
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET stock = stock - i.quantity
    FROM inserted i
    WHERE Products.productId = i.productId;

    IF EXISTS (SELECT 1 FROM Products WHERE stock < 0)
    BEGIN
        RAISERROR('Insufficient stock.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;

INSERT INTO [Categories] (categoryName)
VALUES
('Beverages'),
('Drugs'),
('Snacks');

INSERT INTO [Products] (name, price, stock, categoryId)
VALUES 
('Soda', 300, 10, 1),
('Marijuana', 200, 100, 2),
('Dino Cookies', 100, 50, 3);

INSERT INTO [Customers] (name, email)
VALUES 
('Don Juan', 'ColegioDonJuan@gmail.com'),
('Delio', 'Delio@gmail.com'),
('Dayner', 'Dayner@gmail.com');

INSERT INTO [Orders] (customerId, productId, quantity, orderDate)
VALUES
(1, 2, 10, '2024-06-11'),
(2, 1, 10, '2024-06-11'),
(3, 3, 10, '2024-06-11');

SELECT * FROM [Products];
SELECT * FROM [Orders];

SELECT Orders.orderId, Customers.name AS customer_name, Products.name AS product_name, Orders.quantity, Orders.orderDate
FROM Orders
JOIN Customers ON Orders.customerId = Customers.customerId
JOIN Products ON Orders.productId = Products.productId;

SELECT Customers.name AS customer_name, Products.name AS product_name, Categories.categoryName AS category
FROM Orders
JOIN Customers ON Orders.customerId = Customers.customerId
JOIN Products ON Orders.productId = Products.productId
JOIN Categories ON Products.categoryId = Categories.categoryId
WHERE Products.name = 'Marijuana';
