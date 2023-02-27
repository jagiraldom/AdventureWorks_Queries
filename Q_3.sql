/*
Exercise: List the top 10 best seller products by territory in the last month.

Solution: calculate the date one month ago using the date of the last purchase order
		  filter "SalesOrderHeader" using this date
		  Associate the order header and its order details
		  Group by territory and product id, sum order quantities
		  Rank the total sales of the products for each territory
*/

DECLARE @lastmonth datetime;
SET @lastmonth =  DATEADD(month, -1, (SELECT MAX(soh.OrderDate) FROM Sales.SalesOrderHeader AS soh));

WITH TableProd AS (
	SELECT Header.TerritoryID,
		   Detail.ProductID,
		   SUM(Detail.OrderQty) AS Total_Sales

	FROM (SELECT SalesOrderID, TerritoryID FROM Sales.SalesOrderHeader AS S WHERE S.OrderDate >=@lastmonth) AS Header
		INNER JOIN Sales.SalesOrderDetail AS Detail
			ON Header.SalesOrderID = Detail.SalesOrderID

	GROUP BY TerritoryID, ProductID
),
RankedProd AS(
	SELECT TerritoryID,
		   ProductID,
		   Total_Sales,
		   ROW_NUMBER() OVER(PARTITION BY TerritoryID ORDER BY Total_Sales DESC) AS Rank

	FROM TableProd
)
SELECT *
FROM RankedProd
WHERE Rank <= 10
ORDER BY TerritoryID, Rank;