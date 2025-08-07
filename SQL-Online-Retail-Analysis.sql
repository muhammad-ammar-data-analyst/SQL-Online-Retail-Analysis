-- =================================================================
-- Project: Online Retail Sales Analysis
-- Author:  Muhammad Ammar
-- Date:    August 6, 2025
-- =================================================================

-- == 1. DATABASE AND TABLE SETUP ==
-- The first step is to set up the database and the table schema to hold our raw transactional data.

CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

CREATE TABLE sales_transactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20) NULL,
    description TEXT NULL,
    quantity INT NULL,
    invoice_datetime DATETIME NULL,
    unit_price DECIMAL(10 , 2 ) NULL,
    customer_id INT NULL,
    country VARCHAR(100) NULL
);


-- == 2. DATA LOADING AND CLEANING ==
-- Loading the raw CSV data. The NULLIF() function is used here to handle empty strings during import,
-- ensuring they are correctly stored as NULL values for proper analysis.

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/formatted_fixed.csv'
INTO TABLE sales_transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@invoice_no, @stock_code, @description, @quantity, @invoice_datetime, @unit_price, @customer_id, @country)
SET 
    invoice_no = @invoice_no,
    stock_code = @stock_code,
    description = @description,
    quantity = NULLIF(TRIM(@quantity), ''),
    invoice_datetime = NULLIF(TRIM(@invoice_datetime), ''),
    unit_price = NULLIF(TRIM(@unit_price), ''),
    customer_id = NULLIF(TRIM(@customer_id), ''),
    country = @country;

-- The raw data contains noise. We'll create a new, clean table named 'sales_clean'
-- that only includes valid transactions for our analysis.
-- Rules for cleaning:
-- 1. A CustomerID must exist.
-- 2. Quantity and UnitPrice must be positive.
-- 3. Invoices starting with 'C' (cancellations) are excluded.

CREATE TABLE sales_clean AS SELECT * FROM
    sales_transactions
WHERE
    customer_id IS NOT NULL AND quantity > 0
        AND unit_price > 0
        AND NOT invoice_no LIKE 'C%';


-- == 3. EXPLORATORY DATA ANALYSIS & INSIGHTS ==
-- Now with a clean dataset, we can begin to answer key business questions.

-- Question: Who are our top 10 most valuable customers by total sales?
SELECT 
    customer_id,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unit_price) AS total_sales
FROM
    sales_clean
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- Question: What are the sales trends over time (monthly/quarterly/yearly)?

SELECT 
    YEAR(invoice_datetime) AS Year,
    MONTH(invoice_datetime) AS Month,
    SUM(quantity * unit_price) AS total_sales
FROM
    sales_clean
GROUP BY YEAR(invoice_datetime) , MONTH(invoice_datetime)
ORDER BY total_sales;
    
-- Question: Which countries generate the most sales?

SELECT 
    country, SUM(quantity * unit_price) AS total_sales
FROM
    sales_clean
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10;


-- Question: What is the average order value and how does it change over time?

SELECT 
    Year, Month, AVG(total_sales) AS avg_order_value
FROM
    (SELECT 
        invoice_no,
            SUM(quantity * unit_price) AS total_sales,
            YEAR(invoice_datetime) AS Year,
            MONTH(invoice_datetime) AS Month
    FROM
        sales_clean
    GROUP BY invoice_no , YEAR(invoice_datetime) , MONTH(invoice_datetime)) AS order_totals
GROUP BY Year , Month
ORDER BY Year , Month;



-- Question: What percentage of transactions are returns or credit notes?


SELECT 
    (COUNT(DISTINCT CASE
            WHEN invoice_no LIKE 'C%' THEN invoice_no
            ELSE NULL
        END) * 100.0) / COUNT(DISTINCT invoice_no) AS percentage_transactions_are_returns
FROM
    sales_transactions;

-- Question: Are there products with high return rates?

SELECT 
    stock_code,
    COUNT(DISTINCT invoice_no) AS total_distinct_invoices,
    COUNT(*) AS total_items,
    COUNT(DISTINCT CASE
            WHEN invoice_no LIKE 'C%' THEN invoice_no
            ELSE NULL
        END) AS distinct_return_invoices,
    (COUNT(DISTINCT CASE
            WHEN invoice_no LIKE 'C%' THEN invoice_no
            ELSE NULL
        END) * 100.0) / COUNT(DISTINCT invoice_no) AS return_rate_percentage
FROM
    sales_transactions
GROUP BY stock_code
ORDER BY return_rate_percentage DESC;

-- Question: How does customer retention look (repeat vs. one-time buyers)?

SELECT 
    buyer_type, COUNT(customer_id) AS number_of_customers
FROM
    (SELECT 
        customer_id,
            COUNT(DISTINCT invoice_no) AS distinct_invoices,
            CASE
                WHEN COUNT(DISTINCT invoice_no) = 1 THEN 'One-Time Buyers'
                WHEN COUNT(DISTINCT invoice_no) > 1 THEN 'Repeat Buyers'
            END AS buyer_type
    FROM
        Sales_clean
    GROUP BY customer_id) AS customer_summary
WHERE
    buyer_type IS NOT NULL
GROUP BY buyer_type;

-- Question: What are the busiest sales periods (months)?
SELECT 
    *
FROM
    sales_clean;

SELECT 
    SUM(quantity * unit_price) AS total_sales,
    YEAR(invoice_datetime) AS Year,
    MONTH(invoice_datetime) AS Month
FROM
    sales_clean
GROUP BY YEAR(invoice_datetime) , MONTH(invoice_datetime)
ORDER BY total_sales DESC;
    

-- Question: What are the busiest sales periods (days of week)?

SELECT 
    DayOfWeek,
    total_sales,
    total_transactions,
    CASE DayOfWeek
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS DAYS
FROM
    (SELECT 
        DAYOFWEEK(invoice_datetime) AS DayOfWeek,
            SUM(quantity * unit_price) AS total_sales,
            COUNT(*) AS total_transactions
    FROM
        sales_clean
    GROUP BY DAYOFWEEK(invoice_datetime)) AS sales_summary
ORDER BY total_sales DESC;

-- Question: Are there significant differences in sales performance across countries or regions?
SELECT 
    *
FROM
    sales_clean;
    
    SELECT 
    country,
    SUM(quantity * unit_price) AS total_sales,
    COUNT(DISTINCT invoice_no) AS total_transactions
FROM
    sales_clean
GROUP BY country
ORDER BY total_sales DESC;






    








