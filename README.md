  # Online Retail Sales Analysis
  
  ![License](https://img.shields.io/badge/license-MIT-blue.svg)
  ![SQL](https://img.shields.io/badge/SQL-Analysis-orange.svg)
  ![Data Analysis](https://img.shields.io/badge/Data%20Analysis-Business%20Intelligence-green.svg)
  
  ## Table of Contents
  - [Project Overview](#project-overview)
  - [Business Objective](#business-objective)
  - [Data Source](#data-source)
  - [Project Structure](#project-structure)
  - [Setup & Installation](#setup--installation)
  - [Analysis Methodology](#analysis-methodology)
  - [Key Insights & Business Questions](#key-insights--business-questions)
  - [Technical Implementation](#technical-implementation)
  - [Results & Recommendations](#results--recommendations)
  - [Future Enhancements](#future-enhancements)
  - [Contributing](#contributing)
  - [License](#license)
  
  ## Project Overview
  
  This project performs a comprehensive analysis of online retail sales data to extract meaningful business insights and provide actionable recommendations. Using SQL for data processing and analysis, we examine customer behavior, sales trends, product performance, and regional patterns to help optimize business strategies.
  
  ## Business Objective
  
  The primary goal of this analysis is to transform raw transactional data into strategic business intelligence that can:
  - Identify high-value customers and opportunities for retention
  - Uncover sales trends and seasonal patterns
  - Determine top-performing products and regions
  - Analyse return patterns to minimise losses
  - Optimise inventory and marketing strategies based on data-driven insights
  
  ## Data Source
  
  This analysis utilises the famous **Online Retail Dataset** from the UCI Machine Learning Repository, which contains real-world transactional data from a UK-based online retailer.
  
  - **Dataset**: [Online Retail II UCI Dataset](https://www.kaggle.com/datasets/jillwang87/online-retail-ii)
  - **Time Period**: Multiple years of transactional data
  - **Data Characteristics**: Real-world data with inherent challenges, including null values, cancelled orders, and inconsistencies
  - **Key Attributes**: Invoice numbers, product codes, descriptions, quantities, invoice dates, unit prices, customer IDs, and countries
  
  ## Project Structure
  
  | File/Directory | Description | Purpose |
  |----------------|-------------|---------|
  | `README.md` | Project documentation | Overview, setup instructions, and usage guide |
  | `sales_analysis.sql` | Main SQL analysis script | Contains all SQL queries for data analysis |
  | `data/` | Data directory | Stores raw and processed data files |
  
  
  ## Setup & Installation
  
  ### Prerequisites
  
  - MySQL Server 8.0 or higher
  - CSV data file (formatted_fixed.csv)
  - Basic SQL knowledge
  
  ### Installation Steps
  
  1. **Database Setup**
     ```sql
     CREATE DATABASE IF NOT EXISTS retail_db;
     USE retail_db;
  
  2. **Table Creation**
     ```sql
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
  
  3. **Data Import**
     
     ```sql
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
  
  4. **Data Cleaning**
     ```sql
          CREATE TABLE sales_clean AS SELECT * FROM
              sales_transactions
          WHERE
              customer_id IS NOT NULL AND quantity > 0
                  AND unit_price > 0
                  AND NOT invoice_no LIKE 'C%';
  
  ## Analysis Methodology
  
  Our analysis follows a structured approach:
  
  ### Data Preparation
  - Database and table setup
  - Data import with proper handling of null values
  - Data cleaning to remove invalid transactions
  
  ### Exploratory Analysis
  - Customer value analysis
  - Temporal sales patterns
  - Geographic performance
  - Product performance metrics
  
  ### Advanced Analytics
  - Return rate analysis
  - Customer retention patterns
  - Seasonal trend identification
  - Order value optimisation
  
  ## Key Insights & Business Questions
  
  This analysis addresses critical business questions:
  
  ### Customer Analysis
  - **Top Customers**: Who are our most valuable customers by total sales?
  - **Customer Retention**: What is the ratio of repeat vs. one-time buyers?
  - **Customer Value**: What is the average order value, and how does it change over time?
  
  ### Sales Performance
  - **Temporal Trends**: What are the sales trends over time (monthly/quarterly/yearly)?
  - **Peak Periods**: Which months and days of the week generate the highest sales?
  - **Geographic Performance**: Which countries generate the most sales?
  
  ### Product Analysis
  - **Return Patterns**: What percentage of transactions are returns or credit notes?
  - **Product Returns**: Are there specific products with high return rates?
  
  ## Technical Implementation
  
  ### Database Schema
  The project uses a normalised schema with a primary table for sales transactions:
  - `sales_transactions`: Raw transactional data
  - `sales_clean`: Processed data with invalid transactions removed
  
  ## Key SQL Queries
  
  1. **Top Customers Analysis**
     ```sql
          SELECT 
              customer_id,
              SUM(quantity) AS total_quantity,
              SUM(quantity * unit_price) AS total_sales
          FROM
              sales_clean
          GROUP BY customer_id
          ORDER BY total_sales DESC
          LIMIT 10;
  
  2. **Monthly Sales Trends**
     ```sql
          SELECT 
              YEAR(invoice_datetime) AS Year,
              MONTH(invoice_datetime) AS Month,
              SUM(quantity * unit_price) AS total_sales
          FROM
              sales_clean
          GROUP BY YEAR(invoice_datetime) , MONTH(invoice_datetime)
          ORDER BY total_sales;
  
  3. **Geographic Performance**
     
     ```sql
          SELECT 
              country, SUM(quantity * unit_price) AS total_sales
          FROM
              sales_clean
          GROUP BY country
          ORDER BY total_sales DESC
          LIMIT 10;
  
  4. **Customer Retention Analysis**
     ```sql
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
  ## Results & Recommendations
  
  Based on the analysis, the following business recommendations can be derived:
  
  ### Customer Strategy
  - **Focus on High-Value Customers**: Implement loyalty programs for top customers identified in the analysis
  - **Improve Retention**: Develop targeted campaigns to convert one-time buyers into repeat customers
  - **Personalisation**: Use purchase history to create personalised marketing messages
  
  ### Sales Optimisation
  - **Seasonal Planning**: Allocate marketing budgets to align with peak sales periods
  - **Geographic Expansion**: Prioritise growth in high-performing regions identified in the analysis
  - **Pricing Strategy**: Adjust pricing based on temporal demand patterns
  
  ### Product Management
  - **Return Reduction**: Investigate products with high return rates and address quality or description issues
  - **Inventory Optimisation**: Stock levels should be adjusted based on seasonal demand patterns
  - **Product Bundling**: Create bundles of frequently purchased items together
  
  ## Future Enhancements
  
  Potential improvements for future iterations:
  
  ### Advanced Analytics
  - Customer segmentation using clustering algorithms
  - Market basket analysis to identify product associations
  - Customer lifetime value prediction
  
  ### Visualization
  - Interactive dashboards using tools like Tableau or Power BI
  - Automated reporting with scheduled insights delivery
  
  ### Integration
  - Real-time analysis capabilities
  - Integration with e-commerce platforms for immediate insights
  
  ## Contributing
  
  Contributions to enhance this project are welcome. Please follow these steps:
  
  1. Fork the repository
  2. Create a feature branch (`git checkout -b feature/amazing-feature`)
  3. Commit your changes (`git commit -m 'Add some amazing feature'`)
  4. Push to the branch (`git push origin feature/amazing-feature`)
  5. Open a Pull Request
  
  ## License
  
  This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
  
  ## Acknowledgments
  
  - Dataset provided by the UCI Machine Learning Repository
  - Original data source: Online Retail II UCI Dataset
  - Analysis methodology inspired by best practices in retail analytics
  
  ---
  
  **Author**: Muhammad Ammar  
  **Date**: August 6, 2025  
  **Contact**: [GitHub Profile](https://github.com/muhammad-ammar-data-analyst)
