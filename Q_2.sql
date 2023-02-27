/*
Exercise: List the top 10 most expensive products sold by territory in the last month.

Solution: calculate the date one month ago using the date of the last purchase order
		  filter "SalesOrderHeader" using this date
		  Associate the order header and its order details
		  Rank the unit price of the products for each territory
*/

DECLARE @lastmonth datetime;
SET @lastmonth = DATEADD(month, -1, (SELECT MAX(soh.OrderDate) FROM Sales.SalesOrderHeader AS soh));

WITH TableProd AS (
	SELECT DISTINCT Header.TerritoryID,
					Detail.ProductID,
					Detail.UnitPrice

	FROM (SELECT SalesOrderID, TerritoryID FROM Sales.SalesOrderHeader AS S WHERE S.OrderDate >=@lastmonth) AS Header
		INNER JOIN Sales.SalesOrderDetail AS Detail
			ON Header.SalesOrderID = Detail.SalesOrderID
),
RankedProd AS(
	SELECT TerritoryID,
		   ProductID,
		   UnitPrice,
		   ROW_NUMBER() OVER(PARTITION BY TerritoryID ORDER BY UnitPrice DESC) AS Rank

	FROM TableProd
)
SELECT *
FROM RankedProd
WHERE Rank <= 10
ORDER BY TerritoryID, Rank;
