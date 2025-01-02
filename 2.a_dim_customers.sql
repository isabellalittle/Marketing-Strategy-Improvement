SELECT
	*
FROM
	dbo.customers;

SELECT
	*
FROM
	dbo.geography;

-- SQL statement to join dim_customers with dim_geography to enhance customer data with geographic information:
SELECT 
    c.CustomerID,  -- Selects the unique identifier for each customer
    c.CustomerName,  -- Selects the name of each customer
    c.Email,  -- Selects the email of each customer
    c.Gender,  -- Selects the gender of each customer
    c.Age,  -- Selects the age of each customer
	CASE -- Categorizes the ages into categories: Young Adult(below 36), Middle Age(36-59), or Senior(60+)
		WHEN Age < 36 THEN 'Young Adult'
		WHEN Age BETWEEN 36 AND 59 THEN 'Middle Age'
		ELSE 'Senior'
	END AS AgeCategory,
    g.Country,  -- Selects the country from the geography table
    g.City  -- Selects the city from the geography table

-- We need to make it into table (dbo.) that is actually in the database
INTO dim_customers

FROM 
    dbo.customers as c  -- Specifies the alias 'c' for the dim_customers table
LEFT JOIN -- Because we only want a couple columns from the geography table, but all of the columns from the customers table
    dbo.geography as g  -- Specifies the alias 'g' for the dim_geography table
ON 
    c.GeographyID = g.GeographyID;  -- Joins the two tables on the GeographyID field to match customers with their geographic information
-- This really just makes it more efficient for us, because instead of having 2 separate tables, we were able to combine them into 1 with all the information
-- Both this table and dim_products are 'Dimension'/'Lookup' tables that we will use in PowerBI to filter the 'Fact' tables
