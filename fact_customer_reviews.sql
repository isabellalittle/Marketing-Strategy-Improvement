SELECT
	*
FROM dbo.customer_reviews;

-- Query to clean up ReviewText column (extra whitespaces)
SELECT
	ReviewID, -- Unique identifier for each review
	CustomerID, -- Unique identifier for each customer
	ProductID, -- Unique identifier for each product
	ReviewDate, -- Date of when review was posted
	Rating, -- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized
	REPLACE(ReviewText, '  ', ' ') AS ReviewText

-- We need to make it into table (dbo.) that is actually in the database
INTO fact_customer_reviews

FROM
	dbo.customer_reviews;
-- We are going to run a sentiment analysis on this table in Python later.