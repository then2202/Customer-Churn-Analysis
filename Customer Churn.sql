SELECT * FROM project.customer_churn;

-- DATA CLEANING AND PREP
SELECT
COUNT(DISTINCT `Customer ID`) AS customer_count
FROM
customer_churn

-- check for duplicates in customer ID
SELECT `Customer ID`,
COUNT( `Customer ID` )as count
FROM customer_churn
GROUP BY `Customer ID`
HAVING count(`Customer ID`) > 1;

-- Find the average age of churned customers
SELECT
    AVG(Age) AS average_age_of_churned_customers
FROM
	customer_churn
WHERE
    `Customer Status` = 'Churned';
    
-- Identify the total number of customers and the churn rate
SELECT
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    CASE 
        WHEN COUNT(DISTINCT `Customer ID`) = 0 THEN 0
        ELSE (COUNT(DISTINCT CASE WHEN `Customer Status` = 'Churned' THEN `Customer ID` END) / COUNT(DISTINCT `Customer ID`)) * 100
    END AS churn_rate
FROM
    customer_churn;
    
-- Discover the most common contract types among churned customers
SELECT
    Contract,
    COUNT(*) AS count
FROM
    customer_churn
WHERE
   `Customer Status` = 'Churned'  -- Replace with the actual value indicating churned customers
GROUP BY
    Contract
ORDER BY
    count DESC;
    
-- Analyze the distribution of monthly charges among churned customers
SELECT 
    `Monthly Charge`, 
    COUNT(*) AS Number_of_Customers
FROM 
   customer_churn 
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Monthly Charge`
ORDER BY 
    `Monthly Charge`ASC;
    
-- Create a query to identify the contract types that are most prone to churn
SELECT 
    Contract, 
    COUNT(*) AS Number_of_Churned_Customers
FROM 
    customer_churn
WHERE 
  `Customer Status`= 'Churned'
GROUP BY 
    Contract
ORDER BY 
    Number_of_Churned_Customers DESC;
    
-- Identify customers with high total charges who have churned
SELECT 
    `Customer ID`, 
    `Total Charges`, 
	Contract,
    `Customer Status`, 
    `Churn Reason`
FROM 
   customer_churn
WHERE 
   `Customer Status` = 'Churned'
ORDER BY 
    `Total Charges` DESC;
    
-- Calculate the total charges distribution for churned and non-churned customers
SELECT 
    `Customer Status`,
    COUNT(*) AS Number_of_Customers,
    MIN(`Total Charges`) AS Min_Charges,
    MAX(`Total Charges`) AS Max_Charges,
    AVG(`Total Charges`) AS Avg_Charges,
    SUM(`Total Charges`) AS Total_Charges_Sum
FROM 
    customer_churn
GROUP BY 
    `Customer Status`;
    
-- Calculate the average monthly charges for different contract types among churned customers
SELECT 
    Contract, 
    AVG(`Monthly Charge`) AS Avg_Monthly_Charge
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    Contract
ORDER BY 
    Avg_Monthly_Charge DESC;
    
-- Identify customers who have both online security and online backup services and have not churned
SELECT 
    `Customer ID`, 
    `Online Security`, 
    `Online Backup`, 
    `Customer Status`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Stayed' -- Non-churned customers
    AND `Online Security` = 'Yes'
    AND `Online Backup` = 'Yes';
    
-- Identify the average total charges for customers grouped by gender and marital status
SELECT 
    Gender, 
    Married, 
    AVG(`Total Charges`) AS Avg_Total_Charges
FROM 
    customer_churn
GROUP BY 
    Gender, 
    Married
ORDER BY 
    Gender, 
    Married;

-- Calculate the average monthly charges for different age groups among churned customers
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56 and above'
    END AS Age_Group,
    AVG(`Monthly Charge`) AS Avg_Monthly_Charge
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56 and above'
    END;

-- Calculate the average monthly charges for customers who have multiple lines and streaming TV
SELECT 
    AVG(`Monthly Charge`) AS Avg_Monthly_Charge
FROM 
    customer_churn
WHERE 
    `Multiple Lines` = 'Yes'
    AND `Streaming TV` = 'Yes';

-- Calculate the average monthly charges and total charges for customers who have churned, grouped by the number of dependents
SELECT 
    `Number of Dependents`,
    AVG(`Monthly Charge`) AS Avg_Monthly_Charge,
    SUM(`Total Charges`) AS Total_Charges
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Number of Dependents`;

--  Determine the average age and total charges for customers who have churned, grouped by internet service and phone service
SELECT 
    `Internet Service`,
    `Phone Service`,
    AVG(Age) AS Avg_Age,
    SUM(`Total Charges`) AS Total_Charges
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Internet Service`,
    `Phone Service`;

-- Revenue Lost due to churned customers in Percentage
SELECT 
    (SUM(IF(`Customer Status` = 'Churned', `Total Revenue`, 0)) * 100.0 / SUM(`Total Revenue`)) AS Revenue_Lost_Percentage
FROM 
    customer_churn;
    
 -- Top 5 cities have the highest churn rates
 WITH CityCustomerCounts AS (
    SELECT 
        City,
        COUNT(`Customer ID`) AS Total_Customers,
        SUM(IF(`Customer Status` = 'Churned', 1, 0)) AS Churned_Customers
    FROM 
     customer_churn
    GROUP BY 
        City
    HAVING 
        COUNT(`Customer ID`) >= 20  -- Ensures only cities with at least 20 customers are considered
),
CityChurnRates AS (
    SELECT 
        City,
        Total_Customers,
        Churned_Customers,
        (Churned_Customers * 100.0 / Total_Customers) AS Churn_Rate
    FROM 
        CityCustomerCounts
)
SELECT 
    City,
    Total_Customers,
    Churned_Customers,
    Churn_Rate
FROM 
    CityChurnRates
ORDER BY 
    Churn_Rate DESC
LIMIT 5;
 
 -- Major Churn Reasons
SELECT 
    `Churn Reason`, 
    COUNT(*) AS Number_of_Customers
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Churn Reason`
ORDER BY 
    Number_of_Customers DESC;

-- Identify the customers who have churned, and their contract duration in months (for monthly contracts)
SELECT
    CASE 
        WHEN `Tenure in Months` <= 6 THEN '6 months'
        WHEN `Tenure in Months` <= 12 THEN '1 Year'
        WHEN `Tenure in Months` <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END AS Tenure,
    ROUND(COUNT(`Customer ID`) * 100.0 / SUM(COUNT(`Customer ID`)) OVER(),1) AS Churn_Percentage
FROM
customer_churn
WHERE
`Customer Status` = 'Churned'
GROUP BY
    CASE 
        WHEN `Tenure in Months` <= 6 THEN '6 months'
        WHEN `Tenure in Months` <= 12 THEN '1 Year'
        WHEN `Tenure in Months` <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END ORDER BY Churn_Percentage DESC;

-- How do the churn percentages across different categories correlate with the total revenue lost due to churn
SELECT 
  `Churn Category`,  
  ROUND(SUM(`Total Revenue`),0)AS Churned_Rev,
  CEILING((COUNT(`Customer ID`) * 100.0) / SUM(COUNT(`Customer ID`)) OVER()) AS Churn_Percentage
FROM 
	customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
  `Churn Category`
ORDER BY 
  Churn_Percentage DESC; 
