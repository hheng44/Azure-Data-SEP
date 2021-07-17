WITH t1 AS (SELECT s.StateProvinceID, c.CityID, c.CityName
FROM Application.StateProvinces s
JOIN Application.Cities c
ON s.StateProvinceID = c.StateProvinceID
WHERE s.StateProvinceName NOT IN( 'Alabama', 'Georgia'))


SELECT s.StockItemName, s.StockItemID
FROM
	(SELECT ol.StockItemID
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	JOIN Sales.Customers c
	ON o.CustomerID = c.CustomerID
	JOIN t1
	ON c.PostalCityID = t1.CityID
	WHERE year(o.OrderDate) <> 2014 
	GROUP BY ol.StockItemID)t2
JOIN Warehouse.StockItems s
ON t2.StockItemID = s.StockItemID




