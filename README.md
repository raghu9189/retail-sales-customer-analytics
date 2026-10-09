# Retail Sales Customer Analytics

This project is a beginner-friendly SQL project focused on retail sales and customer analytics. It demonstrates the use of various SQL features to extract meaningful insights from a relational database containing sales, customers, employees, and product data.

## Project Structure

- `SQL_Project_ DA2606_Raghu_Ballu.sql`: The main SQL script containing table creation and a variety of analytical queries.
- `Retail Sales SQL Beginner Project.docx`: Documentation/assignment details related to the project.
- `data/`: Directory for any supporting data files.

## Database Schema

The project uses a database named `skillit` with the following core tables:
- **Customers**: Contains customer information (`CustomerId`, `CustomerName`, `City`, `JoinDate`).
- **Products**: Contains product details (`ProductId`, `ProductName`, `Category`, `Price`).
- **Employees**: Contains employee records (`EmployeeId`, `EmployeeName`, `Department`, `HireDate`).
- **Orders**: Records order events linking customers and employees (`OrderId`, `CustomerId`, `OrderDate`, `EmployeeId`).
- **OrderDetails**: Records line items for each order (`OrderDetailId`, `OrderId`, `ProductId`, `Quantity`).

## SQL Concepts Covered

The SQL queries in this project showcase several key relational database concepts:

1. **Joins**: Extracting data across multiple tables (e.g., matching orders to customers and products).
2. **Subqueries**: Using nested queries for more complex filtering (e.g., finding customers with above-average orders).
3. **Common Table Expressions (CTEs)**: Simplifying complex queries and aggregating data (e.g., total sales calculations, top customers by spending).
4. **Window Functions**: Performing advanced analytical operations like `RANK()`, `ROW_NUMBER()`, and cumulative running totals over specific partitions (e.g., running total of sales for each employee).

## Getting Started

To run the queries:
1. Load the `SQL_Project_ DA2606_Raghu_Ballu.sql` script into your preferred MySQL/MariaDB database management tool.
2. The script begins by creating the `skillit` database and all necessary tables.
3. Execute the queries section by section to observe the analytical results.
