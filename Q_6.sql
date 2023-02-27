/*
Exercise: What is the top 5 customers with the highest purchase for each month and store in the last year.

Solution: set beginning date as the fist day of the current year (last order date)
		  get store, customer and total from order header, take from start_date to last_date
		  calculate total purchase in a specific month for each customer and store
		  rank by store and month
*/

DECLARE @start_date datetime;
DECLARE @last_date datetime;

SET @last_date = (SELECT MAX(soh.OrderDate) FROM Sales.SalesOrderHeader AS soh);
SET @start_date = DATEADD(year,  DATEDIFF(yy, 0, @last_date), 0);

WITH CustomerP AS(
    SELECT 
			C.StoreID,
			MONTH(S.OrderDate) AS Month_s,
			C.CustomerID,
			S.TotalDue

	FROM Sales.SalesOrderHeader AS S
		INNER JOIN Sales.Customer AS C
			ON S.CustomerID = C.CustomerID

    WHERE S.OrderDate >=@start_date AND StoreID IS NOT NULL AND C.CustomerID IS NOT NULL
),
SalesMonth AS (
	SELECT  
			StoreID,
			Month_s,
			CustomerID,
			SUM(TotalDue) AS Total
	FROM CustomerP
	GROUP BY StoreID, Month_s, CustomerID
),

Ranking AS(
	SELECT 
			StoreID,
			Month_s,
			CustomerID,
			Total,
			ROW_NUMBER() OVER(PARTITION BY StoreID, Month_s ORDER BY Total DESC) AS Rank
	FROM SalesMonth
)
SELECT *
FROM Ranking
WHERE Rank <= 5
ORDER BY StoreID, Month_s, Rank;
