/*
Exercise: What is the top 3 stores with the lowest average sales quota for each territory.

(Using Sales quota)
Solution: use the sales quota of the salesperson as the sales quota of the store, then rank sales quota by territory
*/

USE AdventureWorks2019;
WITH Sales_Quota AS (   

	SELECT store.BusinessEntityID AS StoreID, 
		   SalesP.TerritoryID,
		   SalesP.SalesQuota  

	FROM Sales.Store AS Store
		INNER JOIN Sales.SalesPerson AS SalesP
			ON Store.SalesPersonID = SalesP.BusinessEntityID
	),

Ranking AS(
	SELECT  TerritoryID,
		    StoreID,
			ROW_NUMBER() OVER (PARTITION BY TerritoryID ORDER BY SalesQuota) AS Lowest_rank
	FROM Sales_Quota
	)

SELECT * 
FROM Ranking
WHERE Lowest_rank <= 3;