/*
By Jackie Nguyen
github: https://github.com/aznone5
linkedin: https://www.linkedin.com/in/jackie-dan-nguyen/
Dataset download https://archive.ics.uci.edu/dataset/502/online+retail+ii

TASK
Focus on aggerating data to find out ways to improve the buisness by the sales, cusotmer buying habbits, how much they usually like to spend
what country are they from, etc.
*/

-- Create the table to import the dataset
use youtube;

CREATE TABLE retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10 , 2 ),
    CustomerID INT,
    Country VARCHAR(50)
);


-- This dataset has 500,000 rows, in jupyter notebooks, founded on the .ipynb file,  I decided to shorten the dataset and used a randomly selected 30,000 rows instead.
SET SQL_SAFE_UPDATES = 0;


-- count all 30,000 rows
select count(*) from retail;
SELECT 
    *
FROM
    retail;


-- A negative quanity amount doesn't make sense.  Therefore, let's edit it out.
DELETE FROM retail 
WHERE
    Quantity < 0;


-- Monthly sales from each month
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS date,
    SUM(Quantity) AS num_of_sales
FROM
    retail
GROUP BY date , YEAR(InvoiceDate)
ORDER BY date , YEAR(InvoiceDate);

-- Average, Minimum, Maximum, and Standard Deviation for Quantity
SELECT 
    AVG(Quantity) AS avg_quantity,
    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,
    STDDEV(Quantity) AS stddev_quantity
FROM
    retail;

-- Average, Minimum, Maximum, and Standard Deviation for UnitPrice
SELECT 
    AVG(UnitPrice) AS avg_unitprice,
    MIN(UnitPrice) AS min_unitprice,
    MAX(UnitPrice) AS max_unitprice,
    STDDEV(UnitPrice) AS stddev_unitprice
FROM
    retail;

-- Total profit per month
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS date,
    SUM(Quantity * UnitPrice) AS total_sales
FROM
    retail
GROUP BY date
ORDER BY date;

-- Number of purchases per customer
SELECT 
    CustomerID, COUNT(DISTINCT InvoiceNo) AS num_purchases
FROM
    retail
WHERE
    CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY num_purchases DESC
LIMIT 100;

-- Most popular products
SELECT 
    Description, SUM(Quantity) AS total_quantity
FROM
    retail
GROUP BY Description
ORDER BY total_quantity DESC
LIMIT 10;

-- Customer segments based on total spending
SELECT 
    CustomerID,
    SUM(Quantity * UnitPrice) AS total_spending,
    CASE
        WHEN SUM(Quantity * UnitPrice) < 100 THEN 'Low Spender'
        WHEN SUM(Quantity * UnitPrice) BETWEEN 100 AND 500 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS customer_segment
FROM
    retail
WHERE
    CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_spending DESC;

-- Estimate lifetime value based on average spending and a lifetime of 24 months
SELECT 
    CustomerID,
    ROUND(AVG(Quantity * UnitPrice), 2) AS avg_spending,
    ROUND(AVG(Quantity * UnitPrice), 2) * 24 AS estimated_lifetime_value
FROM
    retail
WHERE
    CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY estimated_lifetime_value DESC
limit 100;

-- Products often bought together
SELECT 
    a.Description AS product1,
    b.Description AS product2,
    COUNT(*) AS frequency
FROM
    retail a
        JOIN
    retail b ON a.InvoiceNo = b.InvoiceNo
WHERE
    a.Description != b.Description
GROUP BY product1 , product2
ORDER BY frequency DESC
LIMIT 10;

-- Seasonal trends
SELECT 
    Description,
    DATE_FORMAT(InvoiceDate, '%m') AS month,
    SUM(Quantity) AS total_quantity
FROM
    retail
GROUP BY Description , month
HAVING
    SUM(Quantity) > 500
ORDER BY total_quantity DESC;

-- Seasonal trends for Winter
SELECT 
    Description,
    DATE_FORMAT(InvoiceDate, '%m') AS month,
    SUM(Quantity) AS total_quantity
FROM
    retail
GROUP BY Description , month
HAVING
    SUM(Quantity) > 500
    AND (month = 1
    or month = 11
    or month = 12)
ORDER BY total_quantity DESC;

-- Joining all three tables
SELECT 
    A.CustomerID,
    A.num_purchases,
    B.total_spending,
    B.customer_segment,
    C.avg_spending,
    C.estimated_lifetime_value
FROM
    (SELECT 
        CustomerID, COUNT(DISTINCT InvoiceNo) AS num_purchases
    FROM
        retail
    WHERE
        CustomerID IS NOT NULL
    GROUP BY CustomerID) AS a
        JOIN
    (SELECT 
        CustomerID,
            SUM(Quantity * UnitPrice) AS total_spending,
            CASE
                WHEN SUM(Quantity * UnitPrice) < 100 THEN 'Low Spender'
                WHEN SUM(Quantity * UnitPrice) BETWEEN 100 AND 500 THEN 'Medium Spender'
                ELSE 'High Spender'
            END AS customer_segment
    FROM
        retail
    WHERE
        CustomerID IS NOT NULL
    GROUP BY CustomerID) AS b ON a.CustomerID = b.CustomerID
        JOIN
    (SELECT 
        CustomerID,
            ROUND(AVG(Quantity * UnitPrice), 2) AS avg_spending,
            ROUND(AVG(Quantity * UnitPrice), 2) * 24 AS estimated_lifetime_value
    FROM
        retail
    WHERE
        CustomerID IS NOT NULL
    GROUP BY CustomerID) AS c ON a.CustomerID = C.CustomerID
ORDER BY B.total_spending DESC
LIMIT 100;