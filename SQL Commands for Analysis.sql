DROP DATABASE IF EXISTS emission_db;
CREATE DATABASE IF NOT EXISTS emission_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE emission_db;

DROP TABLE IF EXISTS emissions;
CREATE TABLE emissions (
`year` INT,
`state-name`VARCHAR (20),
`sector-name` VARCHAR(60),
`fuel-name` VARCHAR (15),
`value` DECIMAL (15,8)
);

select count(*) from emissions;
-- TO avoid syntax errors, change the column name 'year' and column names with special characters '-' 
ALTER TABLE emissions
CHANGE COLUMN `year` `emission_year` INT,
CHANGE COLUMN `state-name` `state_name` TEXT,
CHANGE COLUMN `sector-name` `sector_name` TEXT,
CHANGE COLUMN `fuel-name` `fuel_name` TEXT,
CHANGE COLUMN `value` `emission_value` DOUBLE;

USE emission_db;

-- DATA CLEANING AND DATA WRANGLING

-- checking for duplicates
SELECT emission_year, state_name, sector_name, fuel_name, emission_value, COUNT(*)
FROM emissions
GROUP BY emission_year, state_name, sector_name, fuel_name, emission_value
HAVING COUNT(*) > 1;

-- Checking for missing/null values
SELECT *
FROM emissions
WHERE emission_year IS NULL OR state_name IS NULL OR sector_name IS NULL OR fuel_name IS NULL OR emission_value IS NULL;



-- The total emissions from all sectors and for All fuel types would confuse my analysis of emissions from individual sectors and fuel types, so I had to remove the rows for total emissions from all sectors and for All fuel types. Same goes for emissions from united states in the state_name column (which is a collective data of individual states) would confuse my analysis of emissions from individual states, so I had to remove the rows for united states.
DELETE FROM emissions
WHERE sector_name LIKE '%all sectors%' OR state_name LIKE '%united%' OR fuel_name LIKE '%ALL%';

-- To check for potential input errors in state_name, sector_name, and fuel_name columns like unnecessary spaces, mispellings etc

-- View unique values for state name  
 SELECT
		 DISTINCT state_name
FROM emissions;

-- to view unique values for sector  name
SELECT
		DISTINCT sector_name
FROM emissions;

-- to view unique values for fuel name
SELECT
		DISTINCT fuel_name
FROM emissions;

-- Since electric power carbon emissions, industrial power carbon dioxide emissions, commercial power carbon dioxide emissions, and residential carbon dioxide emissions are all sectors of carbon dioxide emissions, it is ideal to rename them to 'electric power' and 'industrial' etc. for easier readability in my visualization

UPDATE emissions
SET sector_name = CASE
		WHEN sector_name = 'Electric Power carbon dioxide emissions' THEN 'Electric Power'
		WHEN sector_name = 'Residential carbon dioxide emissions' THEN 'Residential'
        WHEN sector_name = 'Transportation carbon dioxide emissions' THEN 'Transportation'
        WHEN sector_name = 'Industrial carbon dioxide emissions' THEN 'Industrial'
		WHEN sector_name = 'Commercial carbon dioxide emissions' THEN 'Commercial'
        ELSE sector_name
        END;
        


-- BASIC SUMMARY STATISTICS
SELECT 
		ROUND(SUM(emission_value),2) AS `SUM`,
        ROUND(AVG(emission_value),2) AS "MEAN",
        COUNT(emission_year) AS `COUNTS`,
        ROUND(MAX(emission_value),2) AS `MAX`,
        MIN(emission_value) AS `MIN`
FROM emissions;
-- calculate median
WITH CTE AS (
    SELECT 
        emission_value,
        ROW_NUMBER() OVER (ORDER BY emission_value) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM emissions
)
SELECT 
    ROUND(CASE 
        WHEN total_rows % 2 = 1 THEN 
            (SELECT emission_value 
             FROM CTE
             WHERE row_num = FLOOR(total_rows / 2) + 1)
        ELSE 
            (SELECT AVG(emission_value)
             FROM CTE
             WHERE row_num IN (total_rows / 2, (total_rows / 2) + 1))
    END,2) AS `Median`
FROM CTE
LIMIT 1;
        
	

-- EDA - Explanatory Data Analysis

--  1. Calculate the total amount of carbon di oxide emissions in million metric tons and  observe the trend.
 SELECT emission_year,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY emission_year;


-- 2 How emission of Carbon di oxide changed over decades
 SELECT
		CONCAT(FLOOR(emission_year/10) * 10, "-", FLOOR (emission_year/10) * 10 + 9) AS "decade",
        ROUND(AVG(emission_value),2) AS "Average_emission"
FROM emissions
GROUP BY decade;


 -- 3 - Calculate the percentage contribution of carbon di oxide in million metric tons emission by each sector in all decades.
SELECT	
		CONCAT(FLOOR(emission_year/10) * 10, "-", FLOOR (emission_year/10) * 10 + 9) AS "decade",
        sector_name,
        CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions),4)*100,2),'%') AS "percentage emission"
FROM emissions
GROUP BY decade, sector_name;

 -- 4 Comparing the above result with the percentage contribution of carbon di oxide in million metric tons emission between 2020 and 2021
 SELECT 
		sector_name,
		CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions WHERE emission_year BETWEEN 2020 AND 2021),4)*100,2),'%') AS "percentage emission"
FROM emissions
WHERE emission_year BETWEEN 2020 AND 2021
GROUP BY sector_name;

-- 5 comparing it with the percentage contribution of carbon di oxide in million metric tons emission by fuel type in all decades.
SELECT	
		CONCAT(FLOOR(emission_year/10) * 10, "-", FLOOR (emission_year/10) * 10 + 9) AS "decade",
        fuel_name,
        CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions),4)*100,2),'%') AS "percentage emission"
FROM emissions
GROUP BY decade, fuel_name;

-- 6 Comparing the above result with the percentage contribution of carbon di oxide in million metric tons emission by fuel type between 2020 and 2021
 SELECT 
		fuel_name,
		CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions WHERE emission_year BETWEEN 2020 AND 2021),4)*100,2),'%') AS "percentage emission"
FROM emissions
WHERE emission_year BETWEEN 2020 AND 2021
GROUP BY fuel_name;

-- 7 Total Emission and Percentage change in emission of CO2 from 1970 t0 2021 across all 

WITH CTE AS (
Select 
     state_name,
     ROUND(SUM(emission_value),2) AS 'total_value_97'
   
From emissions
where emission_year = 1970
group by state_name
),

CTE2 AS (
	SELECT
       state_name,
		ROUND(SUM(emission_value),2) AS 'total_value_21'
   
From emissions
where emission_year = 2021
group by state_name
)
        
SELECT
	CTE.state_name,
    CONCAT(ROUND(((total_value_21 - total_value_97) / total_value_97) * 100, 2), '%') AS 'Percentage_Change'
FROM CTE
JOIN CTE2 
ON CTE.state_name = CTE2.state_name;

-- 8 Overall sectors contribution of CO2 emission 

SELECT	
        sector_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY sector_name
ORDER BY total_value desc;

-- 9 Overall state contribution of CO2 emission 
SELECT	
        state_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY state_name
ORDER BY total_value desc;

-- 10 Overall fuel contribution of CO2 emission 
SELECT	
        fuel_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY fuel_name
ORDER BY total_value desc;

-- 11 contribution of CO2 emission by sectors and fuel types 
SELECT	
		sector_name,
        fuel_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY sector_name,fuel_name
ORDER BY total_value;

