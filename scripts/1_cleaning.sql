
SELECT *
FROM superstore
;

-- remove duplicates
-- standardize
-- nulls/blanks
-- remove column

-- DUPLICATES
-- a. create staging
CREATE TABLE superstore_staging
LIKE superstore
;

SELECT *
FROM superstore_staging
;

INSERT INTO superstore_staging
SELECT *
FROM superstore
;

-- b. detection
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Order ID`, `Order Date`, `Ship Date`, `Ship Mode`, `Customer ID`, `Customer Name`, Segment, Country, City, State, `Postal Code`, Region, `Product ID`, Category, `Sub-Category`, `Product Name`, Sales, Quantity, Discount, Profit) AS row_num
FROM superstore_staging
;

-- c. CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Order ID`, `Order Date`, `Ship Date`, `Ship Mode`, `Customer ID`, `Customer Name`, Segment, Country, City, State, `Postal Code`, Region, `Product ID`, Category, `Sub-Category`, `Product Name`, Sales, Quantity, Discount, Profit) AS row_num
FROM superstore_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1
;

-- d. create staging_2 / CTE table
CREATE TABLE `superstore_staging2` (
  `Row ID` int DEFAULT NULL,
  `Order ID` text,
  `Order Date` text,
  `Ship Date` text,
  `Ship Mode` text,
  `Customer ID` text,
  `Customer Name` text,
  `Segment` text,
  `Country` text,
  `City` text,
  `State` text,
  `Postal Code` int DEFAULT NULL,
  `Region` text,
  `Product ID` text,
  `Category` text,
  `Sub-Category` text,
  `Product Name` text,
  `Sales` bigint DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Discount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM superstore_staging2
;

INSERT INTO superstore_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `Order ID`, `Order Date`, `Ship Date`, `Ship Mode`, `Customer ID`, `Customer Name`, 
Segment, Country, City, State, `Postal Code`, Region, `Product ID`, Category, `Sub-Category`, 
`Product Name`, Sales, Quantity, Discount, Profit
) AS row_num
FROM superstore_staging
;

SELECT *
FROM superstore_staging2
WHERE row_num > 1
;

-- e. removing
DELETE
FROM superstore_staging2
WHERE row_num > 1
;

-- STANDARDIZE
-- a. trimming
SELECT *
FROM superstore_staging2
;

SELECT `product name`, (trim(`Product Name`))
FROM superstore_staging2
;

UPDATE superstore_staging2
SET `Product Name` = (trim(`Product Name`))
;

-- b. spelling
SELECT *
FROM superstore_staging2
WHERE category LIKE 'Office%'
;

UPDATE superstore_staging2
SET category = 'Office Supplies'
WHERE category LIKE 'Office%'
;

-- c. format date
SELECT `Order Date`,
str_to_date(`Order Date`, '%m/%d/%Y')
FROM superstore_staging2
;

SELECT `Ship Date`,
str_to_date(`Ship Date`, '%m/%d/%Y')
FROM superstore_staging2
;

UPDATE superstore_staging2
SET `Order Date` = str_to_date(`Order Date`, '%m/%d/%Y')
;
UPDATE superstore_staging2
SET `Ship Date` = str_to_date(`Ship Date`, '%m/%d/%Y')
;

ALTER TABLE superstore_staging2
MODIFY COLUMN `Order Date` DATE;
ALTER TABLE superstore_staging2
MODIFY COLUMN `Ship Date` DATE;

-- NULLS & BLANKS
-- a. detect
SELECT *
FROM superstore_staging2
WHERE Category IS NULL
OR Category = '' 
;

-- b. repopulate if available
-- b1. check
SELECT t1.Category, t2.Category
FROM superstore_staging2 AS t1
JOIN superstore_staging2 AS t2
	ON t1.`Customer Name` = t2.`Customer Name`
WHERE t1.Category IS NULL
AND t2.Category IS NOT NULL
;
-- b2. blanks to null
UPDATE superstore_staging2
SET Category = NULL
WHERE Category = ''
;
-- b3. update
UPDATE superstore_staging2 AS t1
JOIN superstore_staging2 AS t2
	ON t1.`Customer Name` = t2.`Customer Name`
SET t1.Category = t2.Category
WHERE t1.Category IS NULL
AND t2.Category IS NOT NULL
;

-- c. delete nulls/blanks
DELETE 
FROM superstore_staging2
WHERE Category IS NULL
AND `Sub-Category` IS NULL
;

-- REMOVE COLUMN
ALTER TABLE superstore_staging2
DROP COLUMN row_num
;


