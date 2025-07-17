-----------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------- Netflix Project --------------------------------------------------------------- 
-----------------------------------------------------------------------------------------------------------------------------------------------




---------------------------------------------------------------- CREATE TABLE ----------------------------------------------------------------- 

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(250),
	director VARCHAR(550),
	casts VARCHAR(1050),
	country VARCHAR(550),
	date_added VARCHAR(55),
	release_year INT,
	rating VARCHAR(15),
	duration VARCHAR(15),
	listed_in VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS total_content
FROM netflix;

-----------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- Netflix Data Analysis using SQL ---------------------------------------------------------- 
-------------------------------------------------- Solutions of 15 business problems ---------------------------------------------------------- 
-----------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Count the number of Movies vs TV Shows

SELECT 	
	type,
	COUNT(*)
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT 
	type,
	rating
FROM
(
SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT (*) DESC) AS ranking
	/*
	-- RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC): 
	--For each type, it assigns a ranking based on how frequently each rating appears. 
	--The most frequent rating gets ranking = 1.
	*/
)
FROM netflix
GROUP BY 1,2
) AS t1
WHERE 
	ranking = 1 
;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT 
	title,
	type,
	release_year
FROM netflix
WHERE 
	type = 'Movie'
	AND release_year = 2020
ORDER BY title
;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	TRIM(UNNEST(string_to_array(country,','))) AS new_country, -- we need to seperate countries by comma since we have multiple countries in one row which is not nice
	/* 
	-- STRING_TO_ARRAY(country,',') to seperate countries by comma
	-- UNNEST function creates one row and each country will be edited one after one
	-- TRIM function is used to eliminate duplicate values (eg. it shows United States twice)
	*/
	COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
    title,
    CAST(REPLACE(duration, ' min', '') AS INTEGER) AS duration_minutes
	-- REPLACE(duration, ' min', ''): Removes the string ' min' from the duration column. For example, '110 min' becomes '110'.
	-- CAST(... AS INTEGER): Converts the cleaned duration string into an integer
FROM 
    netflix
WHERE 
    type = 'Movie' 
    AND duration IS NOT NULL
ORDER BY 
    duration_minutes DESC
LIMIT 1;

-- 6. Find content added in the last 5 years

SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
/*
-- TO_DATE(date_added, 'Month DD, YYYY'):
	Converts the date_added column (which is a string like 'September 15, 2020') into a proper DATE data type.
	
-- CURRENT_DATE - INTERVAL '5 years':
	Calculates the date exactly 5 years ago from today.
	
-- >=: 
	The filter keeps only the rows where the date_added is on or after the date 5 years ago.
*/

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * 
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND  SPLIT_PART(duration, ' ', 1) ::INT > 5 
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
/*
SPLIT_PART(duration, ' ', 1):
	Splits the duration string by spaces and takes the first part (which is the number of seasons as a string). E.g: '6 Seasons' → '6'
::INT:
	Casts the extracted string into an integer.
*/

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	-- UNNEST(...): Flattens that array into multiple rows — one row per genre per title.
	-- STRING_TO_ARRAY(listed_in, ','): Splits the string into an array of genres. E.g., 'Dramas, International Movies' → ['Dramas', ' International Movies']
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) AS total_release,
	ROUND(COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100,2) AS avg_release
/*
'avg_release' explaination => Calculates the percentage of that year's releases relative to all Indian content.
Formula:
	avg_release =(Titles in year / Total Indian titles) * 100
ROUND(..., 2): Rounds the percentage to two decimal places.
*/	
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';


-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
-- Some entries may have spaces after commas. Use TRIM() to avoid counting " Shah Rukh Khan" and "Shah Rukh Khan" as separate values:
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India'
-- The country col in this dataset contains multiple countries for a single movie or series 
-- which suggests that it may be co-produced internationally by different production houses or it may have gone through a shooting process in different countries. 
-- The 'ILIKE' helps in identifying and selecting if it is from India or was it a part of India.
AND casts IS NOT NULL 
-- If the casts column may contain NULL, you can filter them out
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
  CASE 
    WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
/* 
NOTE: ILIKE is not standard SQL — it’s a PostgreSQL-specific feature.

	The difference between ILIKE and LIKE in SQL (especially in PostgreSQL) is:
1. LIKE – Case-sensitive
Matches patterns with case sensitivity.
'Kill' is not equal to 'kill' or 'KILL'.

2. 🔹 ILIKE – Case-insensitive
Matches patterns without caring about case.
'Kill', 'kill', 'KILL', and 'KiLl' will all match.
*/
    ELSE 'Good'
  END AS content_label,
  COUNT(*) AS total_content
FROM netflix
GROUP BY content_label 
ORDER BY content_label DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------- END ---------------------------------------------------------------------- 
-----------------------------------------------------------------------------------------------------------------------------------------------
