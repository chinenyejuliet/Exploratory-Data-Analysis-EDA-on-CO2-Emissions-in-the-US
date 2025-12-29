# Exploratory-Data-Analysis-EDA-on-CO2-Emissions-in-the-US

## Project Overview

This project aims at using SQL to conduct an Exploratory Data Analysis (EDA) on carbon 
dioxide emissions data across various U.S. states, sectors, and fuel types.

By analyzing these elements, it provides valuable insights into trends in carbon dioxide 
emissions over time, compare emissions across different states and sectors, and understand 
the contribution of various fuel types to overall emissions

***

## Dataset Sources and Description

### Data Source

The data used in this analysis was sourced from [Kaggle](https://www.kaggle.com/datasets/alistairking/u-s-co2-emissions), a popular platform for data science 
and machine learning.  

### Data Overview 
**Period Covered:** This dataset contains carbon dioxide emissions data for various U.S. states from 1970 to 
2021.

**Data Points:**
- state-name: The name of states in the U.S. 
-  sector-name: The sector for which the emissions data is provided, they include:
  - Residential carbon dioxide emissions 
  - Commercial carbon dioxide emissions 
  - Transportation carbon dioxide emissions 
  - Electric Power carbon dioxide emissions 
  - Industrial carbon dioxide emissions 
  - Total carbon dioxide emissions from all sectors
- fuel-name: The type of fuel contributing to the carbon dioxide emissions. The fuel types 
include: 
  -  Coal 
  -  Petroleum 
  - Natural Gas 
  - All Fuels (representing the total emissions from all fuel types combined)  
  

The emissions values are measured in million metric tons (MMT) of carbon 
dioxide. 

### Data Format 
 
For this project, I downloaded and worked with a dataset in CSV format named emissions.csv, which I imported into MySQL Workbench for analysis. Using SQL, I performed 
data cleaning, transformations and complex queries to extract meaningful insights, then used Excel for data visualization. This approach ensured efficient data organization and streamlined analysis.

Note: This project was designed to demonstrate my SQL skills, as per the instructions, which 
required using SQL for data cleaning, transformation, and analysis. An in-depth explanation of the project, including methodology and insights, is provided in the uploaded documentation.

***
## Tools Used
Excel - For data Visualization
MySQL - For data cleaning, data cleaning and EDA.

***
## Data Preparation

### Data Importation

To import the CSV file into MySQL Workbench I used the following steps: 
- Logged into MySQL Workbench and created a database named “emission_db” by 
applying the command

```DROP DATABASE IF EXISTS emission_db; 
CREATE DATABASE IF NOT EXISTS emission_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;
```
- Manage connection and access the database using -> USE emission_db 
- Create a blank table with the following command by applying the 
command

```DROP TABLE IF EXISTS emissions; 
CREATE TABLE emissions ( 
`year` INT, 
`state-name` VARCHAR (20), 
`sector-name` VARCHAR (60), 
`fuel-name` VARCHAR (15), 
`value` DECIMAL (15,8) 
);
```  
Note: Ensure the table structure matches the CSV file's columns. 
- Importing through Command Line Interface: After creating the database and table, I imported the CSV file using the command line interface, as this method takes less time to import data into the database. Steps taken for this procedure were 
mentioned in the A:
  - Go to the command line and show directory path of the MySQL bin path by using -> cd C:\Program Files\MySQL\MySQL Server 8.0\bin 
  - Connect to the MySQL database using -> mysql -u root -p (root is the username and give password) 
  - If you are successfully logged in, set global variables so that data can be successfully imported from a local computer using -> SET GLOBAL local_infile=1; 
  - Quit current server connection using (mysql > quit) 
  - Reconnect to the MySQL server with the local-infile system variable enabled to upload data from a local machine into a file. ->mysql - -local-infile=1 -u root -p (give password) 
  - Show databases in the MySQL server using -> show databases; 
  - Connect to the database that was created for the file using -> use emission_db; 
  - Load the CSV file using the load data statement ->  
```
LOAD DATA LOCAL INFILE 'C:\\Users\\HP\\Downloads\\emissions.csv' 
INTO TABLE emissions 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' IGNORE 1 ROWS; (MySQL, Oracle Corporation, 2024).
```
### Data Cleaning and Data Wrangling 

- TO avoid syntax errors, change the column name 'year' and column names with special characters '-' using this command:
```
ALTER TABLE emissions 
CHANGE COLUMN `year` `emission_year` INT, 
CHANGE COLUMN `state-name` `state_name` TEXT, 
CHANGE COLUMN `sector-name` `sector_name` TEXT, 
CHANGE COLUMN `fuel-name` `fuel_name` TEXT, 
CHANGE COLUMN `value` `emission_value` DOUBLE; 
  ``` 

- Checked for duplicate values in all emissions table columns - using this querry:
```
SELECT emission_year, 
    state_name, 
    sector_name,  
    fuel_name, 
    emission_value,  
    COUNT (*) 
FROM emissions 
GROUP BY emission_year, state_name, sector_name, fuel_name, emission_value 
HAVING COUNT (*) > 1; 
```
  o Result shows that there are no duplicated values in the emissions 
table. 

- Checked for missing/null values in all emissions table columns using the following 
query:
```
SELECT 
    * 
FROM emissions 
WHERE emission_year IS NULL OR state_name IS NULL OR sector_name IS NULL OR fuel_name IS NULL OR emission_value IS NULL;
```  
- Deleted United States' Total emissions from all sectors and all fuel types would confuse my analysis of emissions from individual sectors and fuel types in the sector_name and fuel_name columns. Therefore, I had to remove the rows corresponding to total emissions from all sectors and all fuel types. Similarly, the data for “United States” in the state_name column, which represents a collective aggregation of emissions from individual states, would also interfere with my analysis of emissions at the state level. As a result, I had to remove the rows corresponding to “United States”.  This was achieved by using this query:
```
DELETE FROM emissions 
WHERE sector_name LIKE ‘%all sectors%’ OR state_name LIKE ‘%united%’ OR fuel_name LIKE 
‘%ALL%'; 
```
- View unique values to check for potential input errors in state_name, sector_name and fuel_name columns like unnecessary spaces, mispellings etc.
```
SELECT 
DISTINCT state_name 
FROM emissions;
```
- View unique values for sector_name 
```
SELECT 
DISTINCT sector_name 
FROM emissions;
```
- View unique values for fuel name
```  
SELECT 
DISTINCT fuel_name 
FROM emissions; 
```
- Renamed values in the sector_name field to shorter, Since "Electric Power carbon emissions", "Industrial Power carbon dioxide emissions", "Commercial Power carbon dioxide emissions" and "Residential carbon dioxide emissions" are all sectors of carbon dioxide emissions, it is ideal to rename them to "Electric power", "Industrial", "Commercial" and "Residential" respectively, 
for easier readability in my visualizations. This was done by the following command 
```
UPDATE emissions 
SET sector_name = CASE 
                    WHEN sector_name = 'Electric Power carbon dioxide emissions' THEN 'Electric Power' 
                    WHEN sector_name = 'Residential carbon dioxide emissions' THEN 'Residential' 
                    WHEN sector_name = 'Transportation carbon dioxide emissions' THEN 'Transportation' 
                    WHEN sector_name = 'Industrial carbon dioxide emissions' THEN 'Industrial' 
                    WHEN sector_name = 'Commercial carbon dioxide emissions' THEN 'Commercial' 
         ELSE sector_name 
         END;
```
***

## Summary Statistics 
- **Basic summary statistics for overall CO₂  emission:**
```
  SELECT  
         ROUND (SUM (emission_value),2) AS `SUM`, 
         ROUND (AVG (emission_value),2) AS "MEAN", 
         COUNT (emission_year) AS `COUNTS`, 
         ROUND (MAX (emission_value),2) AS `MAX`,  
         MIN (emission_value) AS `MIN` 
FROM emissions;
```

<img width="286" height="135" alt="histt" src="https://github.com/user-attachments/assets/1bf7ba87-16f5-4dd4-a95c-a9ac9a4abad6" />

Table 1: Basic summary statistics of total CO₂ emission in million metric tons. 

**NOTE:** Most SQL databases do not provide a built-in MEDIAN function. However, the median was 
calculated using a combination of SQL window functions or aggregation. Here's how it was 
achieved: 
```
WITH CTE AS ( 
        SELECT  
           emission_value, 
           ROW_NUMBER() OVER (ORDER BY emission_value) AS row_num, 
           COUNT(*) OVER () AS total_rows 
        FROM emissions 
) 
SELECT  
      ROUND (CASE  
                WHEN total_rows % 2 = 1 THEN (
                    SELECT
                          emission_value  
                    FROM CTE 
                    WHERE row_num = FLOOR (total_rows / 2) + 1
                 ) 
            ELSE  
                  (
                  SELECT
                      AVG(emission_value) 
                  FROM CTE 
                  WHERE row_num IN (total_rows / 2, (total_rows / 2) + 1)
                  ) 
      END,2) AS `Median` 
FROM CTE 
LIMIT 1; 
```
**Observation:**
This statistical summary reveals considerable variability in emissions, with the mean being significantly higher than the median, suggesting the presence of outliers or extreme emission values.

***

## Exploratory Data Analysis 

EDA was Performed to uncover the following patterns before building the dashboard:
- CO2 emission trend in MMT
- Total CO2 emitted in MMT across years
- Emission distribution across sectors
- Distribution of emission fuel type
- CO2 emission across states
***
  
## Data Analysis
Key metrics calculated:
1. Calculate the total amount of carbon di oxide emissions in million metric tons and  observe the trend.
```
SELECT
      emission_year, 
      ROUND (SUM (emission_value),2) AS "total_value" 
FROM emissions
GROUP BY emission_year; 
```

2. How emission of Carbon dioxide emission in million metric tons (MMT) changed over decades.

```
SELECT 
    CONCAT(FLOOR(emission_year/10) * 10, "-", FLOOR (emission_year/10) * 10 + 9) AS "decade", 
    ROUND (AVG (emission_value),2) AS "Average_emission" 
FROM emissions 
GROUP BY decade;
```

3. Calculate the percentage contribution of carbon di oxide in million metric tons emission by each sector in all decades.
  
```
SELECT  
        CONCAT (FLOOR (emission_year/10) * 10, "-",
        FLOOR (emission_year/10) * 10 + 9) AS "decade",  
        sector_name,  
        CONCAT (ROUND (ROUND (SUM (emission_value)/ (SELECT SUM (emission_value) FROM emissions), 4) *100,2),'%') AS "percentage emission"  
FROM emissions GROUP BY decade, sector_name;
```

4. Comparing the above result with the percentage contribution of carbon di oxide in million metric tons emission between 2020 and 2021.

```
 SELECT 
		sector_name,
		CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions WHERE emission_year BETWEEN 2020 AND              2021),4)*100,2),'%') AS "percentage emission"
FROM emissions
WHERE emission_year BETWEEN 2020 AND 2021
GROUP BY sector_name;
```
5. comparing it with the percentage contribution of carbon di oxide in million metric tons emission by fuel type in all decades.

```
SELECT	
		   CONCAT(FLOOR(emission_year/10) * 10, "-", FLOOR (emission_year/10) * 10 + 9) AS "decade",
       fuel_name,
       CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions),4)*100,2),'%') AS "percentage emission"
FROM emissions
GROUP BY decade, fuel_name;
```
6. Comparing the above result with the percentage contribution of carbon di oxide in million metric tons emission by fuel type between 2020 and 2021.

```
 SELECT 
		 fuel_name,
		 CONCAT(ROUND(ROUND(SUM(emission_value)/(SELECT SUM(emission_value) FROM emissions WHERE emission_year BETWEEN 2020 AND               2021),4)*100,2),'%') AS "percentage emission"
FROM emissions
WHERE emission_year BETWEEN 2020 AND 2021
GROUP BY fuel_name;
```

7. Total Emission and Percentage change in emission of CO2 from 1970 t0 2021 across all 

```
WITH CTE AS (
        SELECT 
              state_name,
              ROUND(SUM(emission_value),2) AS 'total_value_97'
   
        FROM emissions
        WHERE emission_year = 1970
        GROUP BY state_name
),

CTE2 AS (
	      SELECT
             state_name,
              ROUND(SUM(emission_value),2) AS 'total_value_21'
   
        FROM emissions
        WHERE emission_year = 2021
        GROUP BY state_name
)
SELECT
	  CTE.state_name,
    CONCAT(ROUND(((total_value_21 - total_value_97) / total_value_97) * 100, 2), '%') AS 'Percentage_Change'
FROM CTE
JOIN CTE2 
ON CTE.state_name = CTE2.state_name;
```
8. Overall sectors contribution of CO2 emission
   
```
SELECT	
        sector_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY sector_name
ORDER BY total_value desc;
```

9. Overall state contribution of CO2 emission.

```
SELECT	
        state_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY state_name
ORDER BY total_value desc;
```

11. Overall fuel contribution of CO2 emission.

 ```
SELECT	
        fuel_name,
        ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY fuel_name
ORDER BY total_value desc;
```

11. contribution of CO2 emission by sectors and fuel type.

```
SELECT	
		  sector_name,
      fuel_name,
      ROUND(SUM(emission_value),2) AS "total_value"
FROM emissions
GROUP BY sector_name,fuel_name
ORDER BY total_value;
```

*** 
## Dashboard 
The analysis was visualized in Excel dashboard.

<img width="800" height="435" alt="emission dashboard" src="https://github.com/user-attachments/assets/15e997cb-6d2d-48c2-bbd9-ac5ca64b75f5" />
 

***

 ## Key Findings
- The comparison between CO₂ emissions in 2020-2021 and the current decade (2020 - 2029) reveals significant differences, likely due to incomplete data for the decade. 
- In 2020-2021, Transportation contributed 37%, a much higher figure than the 1.30% previously reported for the current decade, reinforcing its role as a major emitter. 
- Similarly, Electric Power accounted for 31% in 2020-2021, while the earlier decade figure was only 0.72%, highlighting a large discrepancy. 
- The Industrial sector contributed 20% in the 2020-2021 period compared to 1.12% in the decade’s earlier data, again reflecting incomplete reporting.  
- Residential and Commercial emissions also show notable differences, with 7% and 5% in 2020-2021 compared to 0.18% and 0.24% respectively for the current decade. 
- Overall, the 2020-2021 data confirms that Transportation and Electric Power remain the largest contributors to CO₂ emissions, with significant shares from the Industrial, 
Residential and Commercial sectors. 
- The much lower values reported so far for the 2020-2029 decade suggest incomplete data and it is expected that the full decade's trends will align more closely with the proportions observed in the 2020-2021 period as additional data becomes available. 

***
## Recommendation 
One of the major objectives of analyzing the emission of CO₂ is to understand and manage their impact on the environment. By identifying trends, sources, and sectors contributing to emissions, we can: 
- Generate data-driven insights help encourage the adoption of clean energy, efficient transportation and sustainable industrial practices. 
- Use data analytics to continuously monitor CO₂ emissions across sectors and decades. 
- Discover industries or regions with the highest emissions helps focus efforts on areas with the most significant environmental impact. 
- Reducing CO₂ emissions is critical to slowing global warming.
   
In 2010-2019 average annual global greenhouse gas emissions were at their highest levels in human history, but the rate of growth has slowed. Without immediate and deep emissions reductions across all sectors, limiting global warming to 1.5°C is beyond reach. Limiting global warming will require major transitions in the energy sector.
They involved the following:
- Agriculture, forestry and other land use can provide large-scale emissions reductions and also remove and store carbon dioxide at scale. 
- A substantial reduction in fossil fuel use, widespread electrification, improved energy efficiency and use of alternative fuels such as hydrogen.
- Having the right policies, infrastructure and technology in place to enable changes to our lifestyles and behaviour can result in a 40-70% reduction in greenhouse gas emissions by 2050.. 
- Reducing emissions in industry will involve using materials more efficiently, reusing and recycling products and minimizing waste. 
- Cities and other urban areas also offer significant opportunities for emissions reductions. These can be achieved through lower energy consumption (such as 
by creating compact, walkable cities), electrification of transport in combination with low-emission energy sources and enhanced carbon uptake and storage using nature.

***

## Limitations 
Recent Discrepancies and Incomplete Data: 
The sharp decline observed in emissions for the 2020-2029 period cannot yet be conclusively attributed to energy transition, as the data for the current decade remains incomplete. These values cannot yet be fully ascertained due to incomplete data availability for the current decade as the decade is still ongoing, the trends may shift. However, the specific data for 2020-2021 shows significantly higher emissions, suggesting that reliance on fossil fuels has persisted in the short term.


### **NOTE:***
Additional details about this project are provided in the uploaded PDF.


