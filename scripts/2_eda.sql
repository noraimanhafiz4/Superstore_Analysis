
-- EXPLORATORY DATA ANALYSIS
SELECT *
FROM superstore_staging2
;

-- Sub-Category Profit Margin Analysis
SELECT Category, `Sub-Category`,
sum(Sales) AS total_sales,
round(sum(Profit), 3) AS total_profit,
round((sum(Profit)/sum(Sales)) * 100, 3) AS margin_percent
FROM superstore_staging2
GROUP BY Category, `Sub-Category`
ORDER BY margin_percent DESC
;

-- Shipping Efficiency by Ship Mode
SELECT `Ship Mode`,
AVG(datediff(`Ship Date`, `Order Date`)) AS avg_shiptime
FROM superstore_staging2
GROUP BY `Ship mode`
;

-- Top 10 Most Profitable Clients
SELECT `Customer ID`, `Customer Name`, Segment,
count(`Order ID`) AS total_purchase,
sum(Profit) AS profit,
sum(Sales) AS spent
FROM superstore_staging2
GROUP BY  `Customer ID`, `Customer Name`, Segment
ORDER BY sum(Profit) DESC
LIMIT 10
;

-- Top Products by Regional Demand
SELECT Region, `Product Name`,
sum(Quantity) AS sold
FROM superstore_staging2
GROUP BY Region, `Product Name`
ORDER BY sold DESC
LIMIT 15
;

-- High-Volume, Low-Profit Products
SELECT `Product Name`,
sum(Quantity) AS quantity,
sum(Sales) AS total_sales,
round(sum(Profit), 3) AS total_profit,
round((sum(Profit)/sum(Sales)) * 100, 3) AS margin_percent
FROM superstore_staging2
GROUP BY `Product Name`
ORDER BY margin_percent ASC
LIMIT 10
;



