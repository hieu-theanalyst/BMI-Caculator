-- ------------------------------------------------------------------------------------------
-- ----------------------------------CREATE DATABASE-----------------------------------------
-- ------------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS retail_sales_dbretail_sales;

-- ------------------------------------------------------------------------------------------
-- ----------------------------------CREATE TABLE-------------------------------------------
-- ------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE IF NOT EXISTS retail_sales 
							( 	transaction_id INT PRIMARY KEY,
								sale_date DATE,
                                sale_time TIME,
                                customer_id INT,
                                gender VARCHAR(15),
                                age INT,
                                category VARCHAR(15),
                                quantity INT,
                                price_per_unit FLOAT,
                                cogs FLOAT,
                                total_sale FLOAT
                              ); 


-- ------------------------------------------------------------------------------------------
-- ----------------------------------CLEANING DATA-------------------------------------------
-- ------------------------------------------------------------------------------------------							
SELECT COUNT(*) FROM retail_sales;


SELECT * FROM retail_sales
WHERE 	 
	transaction_id IS NULL
    OR 	
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id IS NULL
    OR
    gender IS NULL
    OR 
    age IS NULL
    OR 
    category IS NULL
    OR
    quantity IS NULL
    OR
    price_per_unit IS NULL
    OR 
    cogs IS NULL
    OR 
    total_sale IS NULL;             
    
    
DELETE FROM retail_sales
WHERE 	 
	transaction_id IS NULL
    OR 	
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    customer_id IS NULL
    OR
    gender IS NULL
    OR 
    age IS NULL
    OR 
    category IS NULL
    OR
    quantity IS NULL
    OR
    price_per_unit IS NULL
    OR 
    cogs IS NULL
    OR 
    total_sale IS NULL;    
    
-- ------------------------------------------------------------------------------------------
-- ----------------------------------Data Exploration----------------------------------------
-- ------------------------------------------------------------------------------------------  
-- How many sales we have?
SELECT COUNT(*) AS total_sale 
FROM retail_sales;


-- How many customers we have?   
SELECT COUNT(DISTINCT customer_id) AS customer_id
FROM retail_sales;
    
    
-- How many categories we have?      
SELECT COUNT(DISTINCT category) AS category
FROM retail_sales; 


-- ------------------------------------------------------------------------------------------
-- --------------------Data Analysis & Business Key Problems & Answers-----------------------
-- ------------------------------------------------------------------------------------------  
-- Q1: Write a SQL query to retrive all columns for sales made on '2022-11-05':
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q2: Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND
	DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
	AND 
    quantity >= 4;
 
 
-- Q3: Write a SQL query to calculate the total sales (total_sale) for each category:
SELECT 
	category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;


-- Q4: Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category:
SELECT 
	ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q5: Write a SQL query to find all transactions where the total_sale is greater than 1000:
SELECT  
	COUNT(transaction_id)
FROM retail_sales
WHERE total_sale > 1000;


-- Q6: Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category:
SELECT 
	category,
    gender,
    COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;


-- Q7: Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:    
SELECT 
	year,
	month,
    avg_total_sale
FROM
( -- Create a subquery then filter the 1st rank 
SELECT 	
	YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    ROUND(AVG(total_sale),2) AS avg_total_sale,
    RANK() OVER(PARTITION BY YEAR(sale_date)
		ORDER BY ROUND(AVG(total_sale), 2) DESC) AS rank_in_year
FROM retail_sales
GROUP BY 1, 2 -- for year and month respectively
) AS t1
WHERE rank_in_year = 1;


-- Q8: Write a SQL query to find the top 5 customers based on the highest total sales: 
SELECT 	
	customer_id,
    SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;


-- Q9: Write a SQL query to find the number of unique customers who purchased items from each category:
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category;


-- Q10: Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
-- I will use CTEs(Common Table Expressions)
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders    
FROM hourly_sale
GROUP BY shift;


-- OR 
SELECT
	CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
		WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
		COUNT(*) AS total_orders
FROM Retail_sales
GROUP BY 1;



-- ------------------------------------------------------------------------------------------
-- ---------------------------------END OF THIS PROJECT!-------------------------------------
-- ------------------------------------------------------------------------------------------  

    
    