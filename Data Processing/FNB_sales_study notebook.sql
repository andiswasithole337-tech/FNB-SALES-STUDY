-- Databricks notebook source
--checking my dataset
SELECT *
FROM fnb.sales.study 
LIMIT 100;

--Checking for NULL values
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN `Cost Of Sales` IS NULL THEN 1 ELSE 0 END) AS null_cost_of_sales,
    SUM(CASE WHEN `Quantity Sold` IS NULL THEN 1 ELSE 0 END) AS null_quantity_sold
FROM fnb.sales.study;

--Counting the record
SELECT COUNT(*) AS total_days
FROM fnb.sales.study;

--Understanding the numbers
SELECT
    MIN(Sales) AS minimum_sales,
    MAX(Sales) AS maximum_sales,
    AVG(Sales) AS average_sales,
    MIN(`Quantity Sold`) AS minimum_quantity,
    MAX(`Quantity Sold`) AS maximum_quantity,
    AVG(`Quantity Sold`) AS average_quantity
FROM fnb.sales.study;

--Checking daily sales price per unit
SELECT
     Date,
     Sales,
     `Quantity Sold`,
     ROUND(Sales / `Quantity Sold`,2) AS Sales_Price_Per_Unit
FROM fnb.sales.study
ORDER BY Date;

--Calculating average selling price for the whole dataset
SELECT
     ROUND(AVG(Sales / `Quantity Sold`),2) AS Average_Unit_Sales_Price
FROM fnb.sales.study;

--Daily gross profit
--(Sales - Cost Of Sales)/ Sales *100
--positive=profit,negative=loss
SELECT
     Date,
     Sales,
     `Cost Of Sales`,
ROUND(((Sales-`Cost Of Sales`)/Sales)*100,2) AS Gross_Profit_Percentage
FROM fnb.sales.study;

--Daily gross profit per unit-Shows how much profit (or loss) was made from each item sold.
--(Sales-Cost)/Quantity
SELECT
    Date,
ROUND((Sales-`Cost Of Sales`)/`Quantity Sold`,2) AS Gross_Profit_Per_Unit
FROM fnb.sales.study;

--promotion periods
SELECT
    Date,
ROUND(Sales/`Quantity Sold`,2) AS Price,
ROUND(AVG(Sales/`Quantity Sold`) OVER(),2) AS Average_Price,
CASE
    WHEN(Sales/`Quantity Sold`)<AVG(Sales/`Quantity Sold`) OVER() THEN 'Promotion'
ELSE 'Normal Price'
END AS Price_Status
FROM fnb.sales.study;

--find promotion periods
SELECT *
FROM
(
SELECT
    Date,
ROUND(Sales/`Quantity Sold`,2) AS Unit_Price,
CASE
    WHEN(Sales/`Quantity Sold`)<AVG(Sales/`Quantity Sold`) OVER() THEN 'Promotion'
ELSE 'Normal'
END AS Promotion
FROM fnb.sales.study
)
WHERE Promotion='Promotion';

--Calculating price elasticity
WITH sales_data AS (
SELECT
    Date,
ROUND(Sales/`Quantity Sold`,2) AS Unit_Price,
`Quantity Sold`
FROM fnb.sales.study
)
SELECT
    Date,
    Unit_Price,
   `Quantity Sold`,
ROUND(
((`Quantity Sold`- LAG(`Quantity Sold`) OVER(ORDER BY Date))/LAG(`Quantity Sold`) OVER(ORDER BY Date))*100,2)
AS Quantity_Change,
ROUND(((Unit_Price - LAG(Unit_Price) OVER(ORDER BY Date))/LAG(Unit_Price) OVER(ORDER BY Date))*100,2) AS Price_Change
FROM sales_data;

--Calculating total sales
SELECT
ROUND(SUM(Sales),2) AS Total_Sales
FROM fnb.sales.study;

--Calculating total profit
SELECT
ROUND(SUM(Sales-`Cost Of Sales`),2) AS Total_Profit
FROM fnb.sales.study;

--Calculating average daily sales
SELECT
ROUND(AVG(Sales) ,2) AS Average_Daily_Sales
FROM fnb.sales.study;

--checking profit status
SELECT
    Date,
    Sales,
    `Cost Of Sales`,
CASE
   WHEN Sales>`Cost Of Sales` THEN 'Profitable'
ELSE 'Loss'
END AS Profit_Status
FROM fnb.sales.study;

--Cleaned table
SELECT
    Date,
    Sales,
    `Cost Of Sales`,
    `Quantity Sold`,

-- Sales Price Per Unit
    ROUND(Sales / `Quantity Sold`, 2) AS sales_price_per_unit,

-- Gross Profit (Rand)
    ROUND(Sales - `Cost Of Sales`, 2) AS gross_profit,

-- Gross Profit %
    ROUND(((Sales - `Cost Of Sales`) / Sales) * 100, 2) AS gross_profit_percentage,

-- Gross Profit Per Unit
    ROUND((Sales - `Cost Of Sales`) / `Quantity Sold`, 2) AS gross_profit_per_unit,

-- Profit Status
CASE
    WHEN Sales > `Cost Of Sales` THEN 'Profitable'
ELSE 'Loss'
END AS profit_status,

-- Promotion Flag
CASE
     WHEN (Sales / `Quantity Sold`) < AVG(Sales / `Quantity Sold`) OVER()THEN 'Promotion'
ELSE 'Normal Price'
END AS promotion_flag,

-- Year
YEAR(Date) AS year,

-- Month Number
MONTH(Date) AS month_number,

-- Month Name
DATE_FORMAT(Date, 'MMMM') AS month_name,

-- Quarter
CONCAT('Q', QUARTER(Date)) AS quarter,

-- Day Name
DATE_FORMAT(Date, 'EEEE') AS day_name

FROM fnb.sales.study;