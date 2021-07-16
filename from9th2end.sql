/*--9th
SELECT s_StockItemID, s.StockItemName, sales_quantity, purchase_quantity
FROM 
(SELECT ol.StockItemID s_StockItemID,  SUM(ol.Quantity) sales_quantity
FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON o.OrderID = ol.OrderID
WHERE DATEPART(yy,o.OrderDate) = 2015
GROUP BY ol.StockItemID) t1
JOIN 
(SELECT pol.StockItemID p_StockItemID, SUM(pol.OrderedOuters * pol.ReceivedOuters) purchase_quantity
FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po
ON pol.PurchaseOrderID = po.PurchaseOrderID
WHERE DATEPART(yy,po.OrderDate) = 2015
GROUP BY pol.StockItemID) t2
ON t1.s_StockItemID = t2.p_StockItemID
JOIN Warehouse.StockItems s
ON t1.s_StockItemID = s.StockItemID
WHERE purchase_quantity > sales_quantity */

/*--10th
SELECT CustomerName, PhoneNumber, PrimaryContactPersonID, t1.StockItemID, StockGroupName
FROM 
	(SELECT c.CustomerName, c.PhoneNumber, c.PrimaryContactPersonID, ol.StockItemID
	FROM sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	WHERE DATEPART(year, o.OrderDate) = 2016) t1
JOIN
	(SELECT sg.StockGroupName, sisg.StockItemID
	FROM Warehouse.StockGroups sg
	JOIN Warehouse.StockItemStockGroups sisg
	ON sg.StockGroupID = sisg.StockGroupID
	WHERE sg.StockGroupName = 'Mugs')t2
ON t1.StockItemID = t2.StockItemID
*/

/*--11th
SELECT CityID, CityName
FROM Application.Cities
WHERE LastEditedBy is not NULL
*/

--12th Stock Item name, delivery address, delivery state, city, 
--country, customer name, customer contact person name, customer phone, quantity
WITH t1 AS 
(SELECt StockItemID, StockItemName
FROM Warehouse.StockItems),
t2 AS
(SELECT c.CityID, c.CityName, co.CountryName
FROM Application.Cities c
JOIN Application.people p
ON c.LastEditedBy = p.PersonID
JOIN Application.Countries co
ON co.LastEditedBy = p.PersonID)

SELECT t1.StockItemName, CustomerName, PhoneNumber, PrimaryContactPersonID, AlternateContactPersonID, 
		DeliveryCityID, DeliveryAddressLine1, DeliveryAddressLine2, CountryName, Quantity, OrderDate
FROM
(SELECT ol.StockItemID, c.CustomerName, c.PhoneNumber, c.PrimaryContactPersonID, C.AlternateContactPersonID, 
		DeliveryCityID, c.DeliveryAddressLine1, c.DeliveryAddressLine2, ol.Quantity, o.OrderDate, c.PostalCityID
FROM Sales.Orders o
JOIN Sales.OrderLines ol
ON o.OrderID = ol.OrderID
JOIN Sales.Customers c
ON o.CustomerID = c.CustomerID
WHERE o.OrderDate = '07-01-2014') t3
JOIN t1 
ON t3.StockItemID = t1.StockItemID
JOIN t2 
ON t3.PostalCityID = t2.CityID



