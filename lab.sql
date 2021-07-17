--lab1
--1st
/*
WITH t3 AS(SELECT sisg.StockItemID, sg.StockGroupName
FROM  [WideWorldImporters].[Warehouse].[StockItemStockGroups] sisg
JOIN [WideWorldImporters].[Warehouse].[StockGroups] sg
ON  sisg.StockGroupID = sg.StockGroupID
WHERE sg.StockGroupName IN ('Toys'))

SELECT CustomerName, CityName, sum_orders
FROM 
	(SELECT c.CustomerName, ci.CityName, c.CustomerID
	FROM Sales.Customers c
	JOIN Application.Cities ci
	ON c.PostalCityID = ci.CityID
	) t1
JOIN
	(SELECT o.CustomerID , SUM(ol.Quantity) sum_orders
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON o.OrderID = ol.OrderID
	AND DATEPART(yy,o.OrderDate) = 2016
	JOIN t3
	ON t3.StockItemID = ol.StockItemID
	GROUP BY o.CustomerID
	) t2
ON t1.CustomerID = t2.CustomerID
WHERE sum_orders > 2000
*/

	/* just test
	WITH t4 AS(SELECT sisg.StockItemID, sg.StockGroupName, sg.StockGroupID
	FROM  [WideWorldImporters].[Warehouse].[StockItemStockGroups] sisg
	JOIN [WideWorldImporters].[Warehouse].[StockGroups] sg
	ON  sisg.StockGroupID = sg.StockGroupID)

	SELECT o.CustomerID , SUM( ol.Quantity) sums
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON o.OrderID = ol.OrderID
	JOIN t4
	ON t4.StockItemID = ol.StockItemID
	WHERE t4.StockGroupID = 9 and DATEPART(yy,o.OrderDate) = 2016
	GROUP BY o.CustomerID */


/*--2nd
SELECT s_StockItemID, s.StockItemName, sales_quantity, purchase_quantity
FROM 
(SELECT ol.StockItemID s_StockItemID,  SUM(ol.Quantity) sales_quantity
FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON o.OrderID = ol.OrderID
WHERE DATEPART(yy,o.OrderDate) = 2016
GROUP BY ol.StockItemID) t1
JOIN 
(SELECT pol.StockItemID p_StockItemID, SUM(pol.OrderedOuters * si.QuantityPerOuter) purchase_quantity
FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po
ON pol.PurchaseOrderID = po.PurchaseOrderID
JOIN Warehouse.StockItems si
ON pol.StockItemID = si.StockItemID
WHERE DATEPART(yy,po.OrderDate) = 2016
GROUP BY pol.StockItemID) t2
ON t1.s_StockItemID = t2.p_StockItemID
JOIN Warehouse.StockItems s
ON t1.s_StockItemID = s.StockItemID
WHERE purchase_quantity > sales_quantity
*/


/*
--3rd

SELECT SUM(t2.Quantity * t2.UnitPrice * sd.DiscountPercentage / 100) possible_loss
FROM 
	(SELECT StockItemID, StockGroupID
	FROM Warehouse.StockItemStockGroups
	WHERE StockGroupID IN (SELECT StockGroupID FROM Sales.SpecialDeals )
	)t1
JOIN
	(SELECT ol.StockItemID, o.OrderDate, ol.Quantity, ol.UnitPrice, c.BuyingGroupID
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	WHERE c.BuyingGroupID  in (SELECT BuyingGroupID FROM Sales.SpecialDeals) 
	) t2
ON t1.StockItemID = t2.StockItemID
JOIN Sales.SpecialDeals sd
ON t2.BuyingGroupID = sd.BuyingGroupID
WHERE t2.OrderDate BETWEEN sd.StartDate and sd.EndDate
*/


































--Lab2
/*--1st
SELECT CustomerID, CustomerName, c.CityName, total_quantity
FROM
(SELECT c.CustomerID, c.CustomerName, c.PostalCityID, total_quantity
FROM Sales.Customers c
JOIN 
	(SELECT c.CustomerID, SUM(ol.Quantity) total_quantity
	FROM Sales.Customers 
	FOR SYSTEM_TIME AS OF  '2013-06-20' c
	JOIN Sales.Orders o
	ON o.CustomerID = c.CustomerID
	JOIN Sales.OrderLines ol
	ON ol.OrderID = o.OrderID
	GROUP BY c.CustomerID) t1
ON c.CustomerID = t1.CustomerID)t2
JOIN Application.Cities c
ON t2.PostalCityID = c.CityID
*/

/*--2nd
SELECT StockItemID, RecommendedRetailPrice, RANK() OVER (PARTITION BY StockItemID ORDER BY RecommendedRetailPrice) ranks
FROM Warehouse.StockItems
FOR SYSTEM_TIME ALL



SELECT ol.StockItemID, ol.UnitPrice, si.RecommendedRetailPrice, o.OrderDate
FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON ol.OrderID = o.OrderID
JOIN Warehouse.StockItems si
ON ol.StockItemID = si.StockItemID
--WHERE si.RecommendedRetailPrice < ol.UnitPrice
ORDER BY ol.StockItemID
*/

/*
SELECT  c.CustomerName, ol.StockItemID, SUM(ol.Quantity) total
FROM Sales.Customers c
JOIN Sales.Orders o 
ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines ol
ON o.OrderID = ol.OrderID
GROUP BY ol.StockItemID, c.CustomerName
ORDER BY c.CustomerName
*/


--3rd
/*
SELECT JSON_VALUE(CustomFields, '$.CountryOfManufacture') Country, COUNT(*)
FROM Warehouse.StockItems
GROUP BY JSON_VALUE(CustomFields, '$.CountryOfManufacture')
*/





--lab3
--1st
/*
SELECT CustomerID, MAX(ConfirmedDeliveryTime) latest_incident
FROM Sales.Invoices
WHERE JSON_VALUE (ReturnedDeliveryData, '$.Events[1].Comment') IS NOT NULL
GROUP BY CustomerID
ORDER BY MAX(ConfirmedDeliveryTime)
*/

--2nd
SELECT t2.CustomerID, num_order
FROM 
	(SELECT  c.CustomerID, c.CustomerName
	FROM Sales.Customers c
	WHERE c.BuyingGroupID is Null) t1
JOIN 
	(SELECT i.CustomerID, COUNT(*) num_order
	FROM Sales.Orders o
	JOIN Sales.Invoices i
	ON i.OrderID = o.OrderID
	WHERE DATEDIFF(day, o.OrderDate, i.ConfirmedDeliveryTime) > 7
	GROUP BY i.CustomerID) t2
ON t1.CustomerID = t2.CustomerID



--3rd
/*
WITH t1 AS(SELECT sisg.StockGroupID, DATEPART(year, o.OrderDate) years, ol.Quantity
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	JOIN Warehouse.StockItemStockGroups sisg
	ON ol.StockItemID = sisg.StockItemID
	)


SELECT StockGroupID total_number, [SELECT years, COUNT(*) cou from t1 group by years]
FROM 
	t1
PIVOT(
	SUM(Quantity)
	for years in ([SELECT years , count(*) cou from t1 group by years])
	) pivot_table
*/