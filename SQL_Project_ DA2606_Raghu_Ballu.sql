CREATE DATABASE skillit;
USE skillit;

-- =========================================
-- TABLE CREATION
-- =========================================

CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    JoinDate DATE
);

CREATE TABLE Products (
    ProductId INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100),
    Category VARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeName VARCHAR(100),
    Department VARCHAR(100),
    HireDate DATE
);

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY AUTO_INCREMENT,
    CustomerId INT,
    OrderDate DATE,
    EmployeeId INT,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerId)
        REFERENCES Customers(CustomerId),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeId)
        REFERENCES Employees(EmployeeId)
);

CREATE TABLE OrderDetails (
    OrderDetailId INT PRIMARY KEY AUTO_INCREMENT,
    OrderId INT,
    ProductId INT,
    Quantity INT,

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderId)
        REFERENCES Orders(OrderId),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductId)
        REFERENCES Products(ProductId)
);


-- =========================================
-- SECTION 1 — JOINS
-- =========================================

-- 1. Display all orders with customer names.

SELECT
    o.OrderId,
    o.CustomerId,
    c.CustomerName,
    o.OrderDate,
    o.EmployeeId
FROM Orders o
JOIN Customers c
    ON o.CustomerId = c.CustomerId;


-- 2. Show product names and quantities for each order.

SELECT
    o.OrderDetailId,
    p.ProductName,
    o.Quantity
FROM OrderDetails o
INNER JOIN Products p
    ON o.ProductId = p.ProductId;


-- 3. Display employee name who handled each order.

SELECT
    e.EmployeeName,
    o.OrderId,
    o.OrderDate
FROM Orders o
INNER JOIN Employees e
    ON o.EmployeeId = e.EmployeeId;


-- 4. Show all customers and their orders
--    (including customers without orders).

SELECT
    c.CustomerId,
    c.CustomerName,
    o.OrderId,
    o.OrderDate
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerId = o.CustomerId;


-- 5. Display total number of orders handled by each employee.

SELECT
    e.EmployeeId,
    e.EmployeeName,
    COUNT(o.OrderId) AS Total_No_Orders
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeId = o.EmployeeId
GROUP BY
    e.EmployeeId,
    e.EmployeeName;


-- =========================================
-- SECTION 2 — SUBQUERIES
-- =========================================

-- 6. Find customers who placed more than 1 order.

SELECT
    CustomerId
FROM Orders
GROUP BY CustomerId
HAVING COUNT(CustomerId) > 1;


SELECT
    *
FROM Customers
WHERE CustomerId IN (
    SELECT
        CustomerId
    FROM Orders
    GROUP BY CustomerId
    HAVING COUNT(CustomerId) > 1
);


-- 7. Display products with price higher than
--    the average product price.

SELECT
    *
FROM Products
WHERE Price > (
    SELECT AVG(Price)
    FROM Products
);


-- 8. Find the customer who placed the highest number of orders.

SELECT
    *
FROM Customers
WHERE CustomerId = (
    SELECT
        CustomerId
    FROM Orders
    GROUP BY CustomerId
    ORDER BY COUNT(OrderId) DESC
    LIMIT 1
);


-- 9. Show orders where total quantity is greater than
--    the average quantity.

SELECT
    OrderId,
    SUM(Quantity) AS Total_Quantity
FROM OrderDetails
GROUP BY OrderId
HAVING SUM(Quantity) > (
    SELECT
        AVG(Total_Quantity_Count)
    FROM (
        SELECT
            OrderId,
            COUNT(Quantity) AS Total_Quantity_Count
        FROM OrderDetails
        GROUP BY OrderId
    ) t
);


-- 10. Find employees who handled more orders
--     than the average employee.

SELECT
    EmployeeId,
    COUNT(OrderId) AS Order_Count
FROM Orders
GROUP BY EmployeeId
HAVING COUNT(OrderId) > (
    SELECT
        AVG(Order_Count)
    FROM (
        SELECT
            EmployeeId,
            COUNT(OrderId) AS Order_Count
        FROM Orders
        GROUP BY EmployeeId
    ) t
);


-- =========================================
-- SECTION 3 — COMMON TABLE EXPRESSIONS (CTEs)
-- =========================================

-- 11. Using CTE, calculate total sales amount for each order.
--     Expected logic: Quantity × Price

WITH Total_Sales_Amount AS (
    SELECT
        od.OrderId,
        SUM(od.Quantity * p.Price) AS Total_Sales
    FROM OrderDetails od
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY od.OrderId
)
SELECT
    *
FROM Total_Sales_Amount;


-- 12. Using CTE, find customers whose total purchase
--     amount is greater than 20,000.

WITH Customers_Total_Purchase AS (
    SELECT
        o.CustomerId,
        SUM(od.Quantity * p.Price) AS Total_Amount
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY o.CustomerId
)
SELECT
    *
FROM Customers_Total_Purchase
WHERE Total_Amount > 20000;


-- 13. Using CTE, display the total revenue generated
--     by each product category.

WITH Revenue_By_Category AS (
    SELECT
        p.Category,
        SUM(od.Quantity * p.Price) AS Total_Amount
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY p.Category
)
SELECT
    *
FROM Revenue_By_Category;


-- 14. Using CTE, find the top 3 customers
--     based on total spending.

WITH Top_Customers_By_Total_Spends AS (
    SELECT
        c.CustomerId,
        c.CustomerName,
        SUM(od.Quantity * p.Price) AS Total_Amount
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Customers c
        ON o.CustomerId = c.CustomerId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY
        c.CustomerId,
        c.CustomerName
)
SELECT
    *
FROM Top_Customers_By_Total_Spends
ORDER BY Total_Amount DESC
LIMIT 3;


-- =========================================
-- SECTION 4 — WINDOW FUNCTIONS
-- =========================================

-- 15. Assign rank to customers based on total purchase amount.
--     Use RANK().

WITH Top_Customers_By_Total_Spends AS (
    SELECT
        c.CustomerId,
        c.CustomerName,
        SUM(od.Quantity * p.Price) AS Total_Amount
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Customers c
        ON o.CustomerId = c.CustomerId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY
        c.CustomerId,
        c.CustomerName
)
SELECT
    *,
    RANK() OVER (
        ORDER BY Total_Amount DESC
    ) AS Rnk
FROM Top_Customers_By_Total_Spends;


-- 16. Display cumulative sales amount by order date.
--     Use SUM() OVER.

WITH Daily_Sales_By_OrderDate AS (
    SELECT
        o.OrderDate,
        SUM(od.Quantity * p.Price) AS Daily_Sales
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Customers c
        ON o.CustomerId = c.CustomerId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY o.OrderDate
)
SELECT
    OrderDate,
    Daily_Sales,
    SUM(Daily_Sales) OVER (
        ORDER BY OrderDate
    ) AS Cumulative_Sales
FROM Daily_Sales_By_OrderDate;


-- 17. Display running total of sales for each employee.

SELECT
    o.EmployeeId,
    o.OrderDate,
    SUM(od.Quantity * p.Price) AS Total_Sales,
    SUM(SUM(od.Quantity * p.Price)) OVER (
        PARTITION BY o.EmployeeId
        ORDER BY o.OrderDate
    ) AS Running_Total
FROM Orders o
JOIN OrderDetails od
    ON o.OrderId = od.OrderId
JOIN Products p
    ON od.ProductId = p.ProductId
JOIN Employees e
    ON o.EmployeeId = e.EmployeeId
GROUP BY
    o.EmployeeId,
    o.OrderDate;


-- 18. Find the highest-priced product in each category.

SELECT
    *
FROM Products;


WITH Ranked_Products AS (
    SELECT
        ProductName,
        Category,
        Price,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY Price DESC
        ) AS Rn
    FROM Products
)
SELECT
    *
FROM Ranked_Products
WHERE Rn = 1;


-- =========================================
-- SECTION 5 — ADDITIONAL QUESTIONS
-- =========================================

-- 21. Find customers who never placed an order.

SELECT
    *
FROM Customers
WHERE CustomerId NOT IN (
    SELECT DISTINCT CustomerId
    FROM Orders
);


-- 22. Find the second highest-selling product.

WITH Product_Sales AS (
    SELECT
        p.ProductId,
        p.ProductName,
        COUNT(p.ProductId) AS Sale_Count
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderId = od.OrderId
    JOIN Products p
        ON od.ProductId = p.ProductId
    GROUP BY
        p.ProductId,
        p.ProductName
),
Ranked_Products AS (
    SELECT
        ProductId,
        ProductName,
        DENSE_RANK() OVER (
            ORDER BY Sale_Count DESC
        ) AS Rnk
    FROM Product_Sales
)
SELECT
    *
FROM Ranked_Products
WHERE Rnk = 2;
