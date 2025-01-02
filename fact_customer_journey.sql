SELECT
	*
FROM dbo.customer_journey;
-- This table looks at the customer journey in a funnel and just looks at the steps they've taken throughout

-- Problems we can see:
	-- Duration column has NULL values
	-- Duplicates in the table

-- We are going to create a CTE (Common Table Expression/a temporary table) to identify and tag DUPLICATE records:
-- This is a 'Verification Query'
WITH DuplicateRecords AS (
    SELECT 
        JourneyID,  -- Unique identifier for each journey
        CustomerID,  -- Unique identifier for each customer
        ProductID,  -- Unique identifier for each product
        VisitDate,  -- Date of the visit, which helps in determining the timeline of customer interactions
        Stage,  -- Stage of the customer journey (e.g., Awareness, Consideration, etc.)
        Action,  -- Action taken by the customer (e.g., View, Click, Purchase)
        Duration,  -- Duration of the action or interaction
        -- Use ROW_NUMBER() to assign a unique row number to each record within the partition defined below
        ROW_NUMBER() OVER (
            -- PARTITION BY groups the rows based on the specified columns that should be unique
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action  
            -- ORDER BY defines how to order the rows within each partition (usually by a unique identifier like JourneyID)
            ORDER BY JourneyID  
        ) AS row_num  -- This creates a new column 'row_num' that numbers each row within its partition (IF ABOVE 1, THAT MEANS IT IS A DUPLICATE ROW)
    FROM 
        dbo.customer_journey
	)

-- Select all records from the CTE where row_num > 1, which indicates duplicate entries
    
SELECT *
FROM DuplicateRecords
WHERE row_num > 1  -- Filters out the first occurrence (row_num = 1) and ONLY shows the duplicates (row_num > 1)
-- There are a total of 79 rows with duplicates
ORDER BY JourneyID;
-- This is all just for us to verify/clean out th duplicate data within the table

-- Now let's actually FIX the table:
-- Outer query selects the final cleaned and standardized data 
-- This is the table that will be going into PowerBI
SELECT 
    JourneyID,  -- Unique identifier for each journey to ensure data traceability
    CustomerID,  -- Unique identifier for each customer to link journeys to specific customers
    ProductID,  -- Unique identifier for each product to analyze customer interactions with different products
    VisitDate,  -- Date of the visit to understand the timeline of customer interactions
    Stage,  -- Uses the uppercased stage value from the subquery for consistency in analysis
    Action,  -- Action taken by the customer (e.g., View, Click, Purchase)
    COALESCE(Duration, avg_duration) AS Duration  -- COALESCE() checks if the first argument (Duration) is NULL. If it is, it returns the second argument (avg_duration).

-- We need to make it into table (dbo.) that is actually in the database
INTO fact_customer_journey

FROM 
    (
        -- Subquery to process and clean the data
        SELECT 
            JourneyID,
            CustomerID,
            ProductID,
            VisitDate, 
            UPPER(Stage) AS Stage,  -- Converts Stage values to uppercase for consistency in data analysis
            Action, 
            Duration,  -- Uses Duration directly, assuming it's already a numeric type
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  -- Calculates the average duration for each date, using only numeric values
			-- The PARTITION BY VisitDate ensures that the average is calculated separately for each date.
            ROW_NUMBER() OVER (
				-- This is just our CTE again, but in a non-temporary form
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action  -- Groups by these columns to identify duplicate records
                ORDER BY JourneyID  -- Orders by JourneyID to keep the first occurrence of each duplicate
            ) AS row_num  -- Assigns a row number to each row within the partition to identify duplicates
        FROM 
            dbo.customer_journey 
    ) AS subquery  -- Names the subquery for reference in the outer query
WHERE 
    row_num = 1;  -- Keeps only the first occurrence of each duplicate group identified in the subquery
-- So, this query removed duplicate and replaced the NULL durations with averages