CREATE DATABASE IF NOT EXISTS coffee_shop_sales_db;

SELECT * 
FROM coffee_shop_sales;

DESCRIBE coffee_shop_sales;


-- ------------------------------------------------------------------------------------------
-- ----------------------------------CLEANING DATA-------------------------------------------
-- ------------------------------------------------------------------------------------------
-- Update table to the particular date/time format
UPDATE coffee_shop_sales
SET transaction_date = str_to_date(transaction_date, '%m/%d/%Y');

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');


-- Change the data type 
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

DESCRIBE coffee_shop_sales;


-- Change the column name
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;



-- -------------------------------------------------------------------------------------
-- ---------------------------------Total Sales Analysis--------------------------------
-- -------------------------------------------------------------------------------------
-- Calculate the total sales for each respective month
SELECT ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5; -- May Month

-- OR
SELECT CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000, 'K') AS total_sales
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 3; -- March Month
    
    
/* 
Determine the month-on-month increase or decrease in sales
-- Calculate the difference in sales between the selected month and the previous month
-- Selected Month / Current Month - May = 5 
--Previous Month - April = 4 
*/
SELECT 
	MONTH(transaction_date) AS month, -- Number of Month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- Total Sales Column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1) -- Month Sales Difference.
		OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty),1) -- Dividion by Previous Month Sales
		OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) IN (4,5) -- for months of April(PM) and May(CM)
GROUP BY 
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
/*
NOTE:
The LAG function is a window function that allows us 
to access data from a previous row in the result set without using a self-join. 
It's especially useful for calculating changes over time, such as month-over-month comparisons.
*/    


/* 
EXPLAINATION:
SELECT clause:
MONTH(transaction_date) AS month: Extracts the month from the transaction_date column and renames it as month.
ROUND(SUM(unit_price * transaction_qty)) AS total_sales: Calculates the total sales by multiplying unit_price and transaction_qty, then sums the result for each month. The ROUND function rounds the result to the nearest integer.
(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) 
OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage with the functions used:
SUM(unit_price * transaction_qty): This calculates the total sales for the current month. It multiplies the unit_price by the transaction_qty for each transaction and then sums up these values.
LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)): This function retrieves the value of the total sales for the previous month. It uses the LAG window function to get the value of the SUM(unit_price * transaction_qty) from the previous row (previous month) ordered by the transaction_date.
(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date))): This part calculates the difference between the total sales of the current month and the total sales of the previous month.
LAG(SUM(unit_price * transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)): This function retrieves the value of the total sales for the previous month again. It's used in the denominator to calculate the percentage increase.
(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) 
OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
OVER (ORDER BY MONTH(transaction_date)): This calculates the ratio of the difference in sales between the current and previous months to the total sales of the previous month. It represents the percentage increase or decrease in sales compared to the previous month.
100: This part multiplies the ratio by 100 to convert it to a percentage.
FROM clause:
coffee_shop_sales: Specifies the table from which data is being selected.
WHERE clause:
MONTH(transaction_date) IN (4, 5): Filters the data to include only transactions from April and May.
GROUP BY clause:
MONTH(transaction_date): Groups the results by month.
ORDER BY clause:
MONTH(transaction_date): Orders the results by month.
*/
    
    
    
-- -----------------------------------------------------------------------------------------------
-- ---------------------------------------Total Orders Analysis-----------------------------------
-- -----------------------------------------------------------------------------------------------
-- Calculate the total number of orders for each respective month
SELECT COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5; -- May Month
    
    
-- Determine the month-on-month increase or decrease in the number of orders
-- Calculate the difference in the number of orders between the selected month and the previous month
SELECT 
	MONTH(transaction_date) AS month, -- Number of Month
    ROUND(COUNT(transaction_id)) AS total_orders, -- Total Orders Column
    (COUNT(transaction_id) - LAG(COUNT(transaction_id),1) -- Month Sales Difference. NOTE: LAG is a window function
		OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id),1) -- Dividion by Previous Month Sales
		OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) IN (4,5) -- for months of April(PM) and May(CM)
GROUP BY 
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
    
    
-- -------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Total Quantity Sold Analysis------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- Calculate the total quantity sold for each respective month
SELECT SUM(transaction_qty) AS total_quantity_sold
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5; -- May Month


-- Determine the month-on-month increase or decrease in the total quantity sold 
-- Calculate the difference in the total quantity sold between the selected month and the previous month
SELECT 
	MONTH(transaction_date) AS month, -- Number of Month
    ROUND(SUM(unit_price * transaction_qty)) AS total_quantity_sold, -- total_quantity Column
    (SUM(transaction_qty) - LAG(SUM(transaction_qty),1) -- Month Sales Difference. NOTE: LAG is a window function
		OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty),1) -- Dividion by Previous Month Sales
		OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) IN (4,5) -- for months of April(PM) and May(CM)
GROUP BY 
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);
    
    
    
-- -------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Calendar Heat Map-----------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
SELECT 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/ 1000, 1), 'K') AS total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/ 1000, 1), 'K') AS total_qty_sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18'; -- Change particular date



-- -------------------------------------------------------------------------------------------------------------
-- -----------------------------------Sales Analysis by Weekdays and Weekends-----------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- Segment sales data into weekdays and weekends to analyze performance variations
-- Provide insights into whether sales patterns differ significantly between weekdays and weekends
-- Weekends - Sat and Sun
-- Weekdays - Mon to Fri
SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' 
    ELSE 'Weekdays'
    END AS day_type,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May Month
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' 
    ELSE 'Weekdays'
    END;


-- OR use CONCAT function to round up
    SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' 
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May Month
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends' 
    ELSE 'Weekdays'
    END;
    
-- ------------------------------------------------------------------------------------------
-- --------------------Sales Analysis by Store Location--------------------------------------
-- ------------------------------------------------------------------------------------------
-- Highlight MoM sales increase or decrease for each store location to identify trends    
SELECT store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May Month
GROUP BY store_location
ORDER BY total_sales DESC;
 
-- ----------------------------------------------------------------------------------------
-- -------------------------------Daily Sales Analysis-------------------------------------
-- ----------------------------------------------------------------------------------------
SELECT AVG(unit_price * transaction_qty) AS avg_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;    

SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000, 1),'K') AS avg_sales
FROM 
	(
    SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 
    GROUP BY transaction_date
    ) AS internal_query;
   
   
-- Daily Sales for Month Selected
SELECT 
	DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
GROUP BY DAY(transaction_date)
ORDER BY total_sales DESC;


	/*
COMPARING DAILY SALES WITH AVERAGE SALES  
-> IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
*/        
 SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    
-- ----------------------------------------------------------------------------------------
-- -------------------------Sales Analysis by Product Catergory----------------------------
-- ----------------------------------------------------------------------------------------
-- Analyze sales performance across different product catergories
-- Provide insights into which product categories contribute the most to overall sales
SELECT 
	product_category,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM coffee_shop_sales
	WHERE MONTH(transaction_date) = 5 -- Filter for May
	GROUP BY product_category
	ORDER BY total_sales DESC;


-- ----------------------------------------------------------------------------------------
-- -------------------------------Top 10 Products by Sales---------------------------------
-- ----------------------------------------------------------------------------------------
-- Identify and display the top 10 products based on sales volume
-- Allow users to quickly visualize the best-performing products in terms of sales
SELECT 
	product_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee' -- Filter for May and particular product in this case is coffee
	GROUP BY product_type
	ORDER BY total_sales DESC
	LIMIT 10; -- Display Top 10 by using LIMIT function


-- ----------------------------------------------------------------------------------------
-- --------------------------Sales Analysis by Days and Hours------------------------------
-- ----------------------------------------------------------------------------------------
-- Visualize patterns by days and hours
SELECT 
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales,
    ROUND(SUM(transaction_qty),2) AS total_qty_sold,
    COUNT(*)
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 /*Filter for May*/ 
			AND DAYOFWEEK(transaction_date) = 2 /*Filter for Monday*/
			AND HOUR(transaction_time) = 8; /*Hour No 8*/
    
    
-- Display all hours
SELECT 
	HOUR(transaction_time),
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
    GROUP BY HOUR(transaction_time)
    ORDER BY HOUR(transaction_time) DESC;


-- To get sales from Monday to Sunder for Month of May
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May 
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END ;

-- ----------------------------------------------------------------------------------------
-- -----------------------------END OF THIS PROJECT! YAYYYY--------------------------------
-- ----------------------------------------------------------------------------------------