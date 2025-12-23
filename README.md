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

## Data Preperation

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

