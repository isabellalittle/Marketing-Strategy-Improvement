SELECT
	*
FROM dbo.products;
-- We're going to start by looking at the product data.

-- Every product category = 'Sports', so we are going to remove that column

-- Query to categorize products based on their price:
-- This is to make it a bit easier on ShopEasy to have an understanding of what category of products their customers are buying
SELECT
	ProductID, -- Unique identifier for each product
	ProductName, -- Name of each product
	Price, -- Price of each product

CASE -- Categorizes the products into price categories: Low($50), Medium, or High($200)
	WHEN Price < 50 THEN 'Low'
	WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
	ELSE 'High'
END AS PriceCategory

-- We need to make it into table (dbo.) that is actually in the database
INTO dim_products

FROM
	dbo.products;
