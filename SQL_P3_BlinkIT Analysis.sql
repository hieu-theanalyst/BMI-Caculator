ALTER TABLE blinkit_grocery_data RENAME COLUMN `ï»¿Item Fat Content` TO `Item Fat Content`;

SELECT * 
FROM blinkit_grocery_data;

SELECT COUNT(*) 
FROM blinkit_grocery_data;

UPDATE blinkit_grocery_data
SET `Item Fat Content`=
CASE
WHEN `Item Fat Content` IN ('LF', 'low fat') THEN 'Low Fat'
WHEN `Item Fat Content` = 'reg' THEN 'Regular'
ELSE `Item Fat Content`
END;

SELECT DISTINCT `Item Fat Content`FROM blinkit_grocery_data;

SELECT CAST(SUM(`Total Sales`) / 100000 AS DECIMAL(10,2)) AS Total_Sales_Millions 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022;

SELECT CAST(AVG(`Total Sales`) AS DECIMAL(10,2)) AS Avg_Sales 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022;

SELECT COUNT(*) AS No_Of_Items 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022;

SELECT CAST(AVG(`Rating`) AS DECIMAL(10,2)) AS Avg_Rating 
FROM blinkit_grocery_data;

SELECT `Item Fat Content`, 
	CAST(SUM(`Total Sales`)/100 AS DECIMAL(10,2)) AS Total_Sales_Thousands,
	CAST(AVG(`Total Sales`) AS DECIMAL(10,1)) AS Avg_Sales,
	COUNT(*) AS No_Of_Items, 
	CAST(AVG(`Rating`) AS DECIMAL(10,2)) AS Avg_Rating 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022
GROUP BY `Item Fat Content`
ORDER BY `Total_Sales_Thousands` DESC;

SELECT `Item Type`, 
	CAST(SUM(`Total Sales`) AS DECIMAL(10,2)) AS Total_Sales,
	CAST(AVG(`Total Sales`) AS DECIMAL(10,1)) AS Avg_Sales,
	COUNT(*) AS No_Of_Items, 
	CAST(AVG(`Rating`) AS DECIMAL(10,2)) AS Avg_Rating 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022
GROUP BY `Item Type`
ORDER BY `Total_Sales` DESC;

SELECT `Outlet Location Type`, `Item Fat Content`,
	CAST(SUM(`Total Sales`) AS DECIMAL(10,2)) AS Total_Sales,
	CAST(AVG(`Total Sales`) AS DECIMAL(10,1)) AS Avg_Sales,
	COUNT(*) AS No_Of_Items, 
	CAST(AVG(`Rating`) AS DECIMAL(10,2)) AS Avg_Rating 
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022
GROUP BY `Outlet Location Type`, `Item Fat Content`
ORDER BY `Total_Sales` ASC;

SELECT `Outlet Location Type`, `Item Fat Content`,
	CAST(SUM(`Total Sales`) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_grocery_data
WHERE `Outlet Establishment Year` = 2022
GROUP BY `Outlet Location Type`, `Item Fat Content`
ORDER BY `Total_Sales` ASC;

SELECT 
  `Outlet Location Type`,
  CAST(SUM(CASE WHEN `Item Fat Content` = 'Low Fat' THEN `Total Sales` ELSE 0 END) AS DECIMAL(10,2)) AS Low_Fat,
  CAST(SUM(CASE WHEN `Item Fat Content` = 'Regular' THEN `Total Sales` ELSE 0 END) AS DECIMAL(10,2)) AS Regular
FROM blinkit_grocery_data
GROUP BY `Outlet Location Type`
ORDER BY `Outlet Location Type`;

