--1st
/*WITH t3 AS(SELECT sisg.StockItemID, sg.StockGroupName
FROM  [WideWorldImporters].[Warehouse].[StockItemStockGroups] sisg
JOIN [WideWorldImporters].[Warehouse].[StockGroups] sg
ON  sisg.StockGroupID = sg.StockGroupID)

SELECT CustomerName, CityName
FROM 
	(SELECT c.CustomerName, ci.CityName, c.CustomerID
	FROM Sales.Customers c
	JOIN Application.Cities ci
	ON c.PostalCityID = ci.CityID
	) t1
JOIN
	(SELECT o.CustomerID , DATEPART(yy,o.OrderDate) years, ol.Quantity
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON o.OrderID = ol.OrderID
	AND DATEPART(yy,o.OrderDate) = 2016
	JOIN t3
	ON t3.StockItemID = ol.StockItemID
	WHERE t3.StockGroupName = 'toy'
	) t2
ON t1.CustomerID = t2.CustomerID
--GROUP BY CustomerName, CityName
--HAVING SUM(Quantity) > 2000*/




/*
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
(SELECT pol.StockItemID p_StockItemID, SUM(pol.OrderedOuters * pol.ReceivedOuters) purchase_quantity
FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po
ON pol.PurchaseOrderID = po.PurchaseOrderID
WHERE DATEPART(yy,po.OrderDate) = 2016
GROUP BY pol.StockItemID) t2
ON t1.s_StockItemID = t2.p_StockItemID
JOIN Warehouse.StockItems s
ON t1.s_StockItemID = s.StockItemID
WHERE purchase_quantity > sales_quantity*/

--3rd
SELECT  SUM(original_profit*DiscountPercentage/100) possible_loss
FROM 
	(SELECT ol.StockItemID,  o.OrderDate, SUM(ol.UnitPrice*ol.Quantity) original_profit
	FROM Sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	GROUP BY ol.StockItemID, o.OrderDate) t1
JOIN
	(SELECT sg.StockGroupID, sisg.StockItemID, sd.StartDate, sd.EndDate, sd.DiscountPercentage
	FROM Warehouse.StockGroups sg
	JOIN Warehouse.StockItemStockGroups sisg
	ON sg.StockGroupID = sisg.StockGroupID
	JOIN Sales.SpecialDeals sd
	ON sg.StockGroupID = sd.StockGroupID)t2
ON t1.StockItemID = t2.StockItemID
WHERE OrderDate Between StartDate and EndDate


