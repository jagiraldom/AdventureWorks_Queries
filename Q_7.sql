/*
Exercise: List the top 5 best seller products by sales person in the last three months.

Solution: calculate the date three month ago using the date of the last purchase order
		  filter "SalesOrderHeader" using this date
		  Associate the order header and its order details
		  Group by sales person and product id, sum order quantities
		  Rank the total sales of the products for each vendor
*/

DECLARE @last_three_months datetime;
SET @last_three_months = DATEADD(month, -3, (SELECT MAX(soh.OrderDate) FROM Sales.SalesOrderHeader AS soh));

WITH Sales AS (
	SELECT Header.SalesPersonID,
		   Detail.ProductID,
		   SUM(Detail.OrderQty) AS Total_Sales

	FROM (SELECT SalesOrderID, SalesPersonID FROM Sales.SalesOrderHeader AS S WHERE S.OrderDate >=@last_three_months) AS Header
		INNER JOIN Sales.SalesOrderDetail AS Detail
			ON Header.SalesOrderID = Detail.SalesOrderID

	GROUP BY SalesPersonID, ProductID
),
RankedSales AS(
	SELECT SalesPersonID,
		   ProductID,
		   Total_Sales,
		   ROW_NUMBER() OVER(PARTITION BY SalesPersonID ORDER BY Total_Sales DESC) AS Rank

	FROM Sales
)
SELECT *
FROM RankedSales
WHERE (SalesPersonID IS NOT NULL) AND Rank <= 5 
ORDER BY SalesPersonID, Rank;
