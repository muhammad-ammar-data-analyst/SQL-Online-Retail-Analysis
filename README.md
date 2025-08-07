# 🛒 ONLINE RETAIL SALES ANALYSIS USING SQL

## 📌 OVERVIEW
This project performs a comprehensive analysis of transactional data from a UK-based online retail store. Using SQL, we clean the raw dataset, structure it for analysis, and extract actionable business insights to understand customer behavior, sales trends, and operational performance.

## 📂 DATASET
The dataset is sourced from the UCI Machine Learning Repository, containing:

- **Rows:** 541,909 transactions  
- **Columns:** Invoice No, Stock Code, Description, Quantity, Invoice DateTime, Unit Price, Customer ID, Country  
- **Timeframe:** December 1, 2010 – December 9, 2011  
- **Source:** [UCI Online Retail Dataset](https://archive.ics.uci.edu/ml/datasets/online+retail)

## 🧰 TOOLS & TECHNOLOGIES
- **MySQL**: Database & SQL engine  
- **SQL**: Data cleaning & analysis

## 🧼 DATA CLEANING PROCESS
To ensure reliable insights, the raw data was cleaned using the following rules:

- Only include records with a valid `CustomerID`  
- Exclude cancelled transactions (`InvoiceNo` starting with `'C'`)  
- Filter out entries with non-positive `Quantity` or `UnitPrice`  
- Create a new table `sales_clean` for validated data

## 📊 KEY BUSINESS QUESTIONS ANSWERED

### 🔝 Top Customers
**Query:**
```sql
SELECT customer_id, SUM(quantity * unit_price) AS total_sales
FROM sales_clean
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;
