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
SELECT CustomerName, SUM(Quantity) sum_quan
FROM 
	(SELECT c.CustomerName, c.PhoneNumber, c.PrimaryContactPersonID, ol.StockItemID, ol.Quantity
	FROM sales.OrderLines ol
	JOIN Sales.Orders o
	ON ol.OrderID = o.OrderID
	JOIN Sales.Customers c
	ON c.CustomerID = o.CustomerID
	WHERE DATEPART(year, o.OrderDate) = 2016) t1
JOIN
	(SELECT si.StockItemID
	FROM Warehouse.StockItems si
	WHERE si.StockItemName LIKE '%mug%')t2
ON t1.StockItemID = t2.StockItemID
GROUP BY CustomerName
HAVING SUM(Quantity) <= 10
*/


/*--11th
SELECT c.CityName, open_date
FROM 
	(SELECT c.AccountOpenedDate open_date, c.PostalCityID
	FROM Sales.Customers c
	WHERE c.AccountOpenedDate > '2015-01-01') t1
JOIN 
	Application.Cities c
ON 
	c.CityID = t1.PostalCityID

UNION 

SELECT c.CityName, open_date
FROM 
	(SELECT CAST(s.ValidFrom AS DATE) open_date, s.PostalCityID
	FROM Purchasing.Suppliers s
	WHERE CAST(s.ValidFrom AS DATE)> '2015-01-01')t2
JOIN
	Application.Cities c
ON
	c.CityID = t2.PostalCityID
*/



/*--12th Stock Item name, delivery address, delivery state, city, 
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
*/


/*--13th
/*SELECT ol.StockItemID, SUM(ol.Quantity) sum_sales
FROM Sales.OrderLines ol
JOIN Sales.Orders o
ON ol.OrderID = o.OrderID
GROUP BY ol.StockItemID
ORDER BY ol.StockItemID


SELECT pol.StockItemID, SUM(pol.OrderedOuters * si.QuantityPerOuter) sum_purchase
FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po
ON pol.PurchaseOrderID = po.PurchaseOrderID
JOIN Warehouse.StockItems si
ON pol.StockItemID = si.StockItemID
GROUP BY pol.StockItemID
ORDER BY pol.StockItemID
*/

SELECT t3.StockGroupName, -t3.sales_quantity sales_quantity, t4.purchases_quantity purchase_quantity, (t4.purchases_quantity + t3.sales_quantity) remaining_stcok
FROM
	(SELECT sg.StockGroupName, SUM(sales_quantity) sales_quantity
	FROM 
		(SELECT StockItemID, Quantity sales_quantity
		FROM Warehouse.StockItemTransactions
		WHERE SupplierID is NULL)t1
	JOIN Warehouse.StockItemStockGroups sisg
	ON t1.StockItemID = sisg.StockItemID
	JOIN Warehouse.StockGroups sg
	ON sisg.StockGroupID = sg.StockGroupID
	GROUP BY sg.StockGroupName ) t3

JOIN

	(SELECT sg.StockGroupName, SUM(purchases_quantity) purchases_quantity
	FROM 	
			(SELECT StockItemID, Quantity purchases_quantity
			FROM Warehouse.StockItemTransactions
			WHERE SupplierID IS NOT Null) t2
	JOIN Warehouse.StockItemStockGroups sisg
	ON t2.StockItemID = sisg.StockItemID
	JOIN Warehouse.StockGroups sg
	ON sisg.StockGroupID = sg.StockGroupID
	GROUP BY sg.StockGroupName) t4
ON t3.StockGroupName = t4.StockGroupName
*/

/*--14th
SELECT t3.DeliveryCityID, t4.StockItemID, t3.max_num
FROM 
	(SELECT t1.DeliveryCityID, MAX(t1.total_received) max_num
	FROM 
		(SELECT c.DeliveryCityID, il.StockItemID, SUM(il.Quantity) total_received
		FROM Sales.InvoiceLines il
		JOIN Sales.Invoices i
		ON i.InvoiceID = il.InvoiceID
		JOIN Sales.Customers c
		ON i.CustomerID = c.CustomerID
		WHERE DATEPART(yy, i.ConfirmedDeliveryTime) = '2016' and JSON_VALUE (ReturnedDeliveryData, '$.Events[1].Status') IS NOT NULL
		GROUP BY c.DeliveryCityID, il.StockItemID
		) t1

	JOIN 
		(
		SELECT c.CityName, co.CountryName, sp.StateProvinceName, c.CityID
		FROM Application.StateProvinces sp
		JOIN Application.Countries co
		ON sp.CountryID = co.CountryID AND co.CountryName = 'United States'
		JOIN Application.Cities c
		ON sp.StateProvinceID = c.StateProvinceID
		) t2

	ON t1.DeliveryCityID = t2.CityID
	GROUP BY t1.DeliveryCityID) t3

JOIN 

	(SELECT t1.DeliveryCityID, t1.StockItemID
	FROM 
		(SELECT c.DeliveryCityID, il.StockItemID, SUM(il.Quantity) total_received
		FROM Sales.InvoiceLines il
		JOIN Sales.Invoices i
		ON i.InvoiceID = il.InvoiceID
		JOIN Sales.Customers c
		ON i.CustomerID = c.CustomerID
		WHERE DATEPART(yy, i.ConfirmedDeliveryTime) = '2016' and JSON_VALUE (ReturnedDeliveryData, '$.Events[1].Status') IS NOT NULL
		) t1

	JOIN 
		(SELECT c.CityName, co.CountryName, sp.StateProvinceName, c.CityID
		FROM Application.StateProvinces sp
		JOIN Application.Countries co
		ON sp.CountryID = co.CountryID AND co.CountryName = 'United States'
		JOIN Application.Cities c
		ON sp.StateProvinceID = c.StateProvinceID
		) t2
	ON t1.DeliveryCityID = t2.CityID
	) t4
ON t3.DeliveryCityID = t4.DeliveryCityID
*/


--15th
/*
SELECT OrderID
FROM Sales.Invoices
WHERE JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Comment') IS NOT NULL
*/

--16th
/*
SELECT StockItemName, JSON_VALUE(CustomFields, '$.CountryOfManufacture')
FROM Warehouse.StockItems
WHERE JSON_VALUE(CustomFields, '$.CountryOfManufacture') = 'China'
*/

--17th
/*
SELECT JSON_VALUE(CustomFields, '$.CountryOfManufacture') MANUFACTURE_country, SUM(Quantity) total_sales
FROM Sales.OrderLines ol
JOIN Warehouse.StockItems si
ON ol.StockItemID = si.StockItemID
GROUP BY JSON_VALUE(CustomFields, '$.CountryOfManufacture')
*/

--18th
/*
CREATE VIEW sales_per_year1
AS
SELECT  StockGroupName, [2013], [2014], [2015], [2016], [2017]
FROM 
	(SELECT sg.StockGroupName, year(o.OrderDate) years, ol.Quantity
	FROM Sales.OrderLines ol
	JOIN Warehouse.StockItemStockGroups sisg
	ON ol.StockItemID = sisg.StockItemID
	JOIN Warehouse.StockGroups sg
	ON sisg.StockGroupID = sg.StockGroupID
	JOIN Sales.Orders o
	ON o.OrderID = ol.OrderID
	WHERE year(o.OrderDate) IN (2013, 2014, 2015, 2016, 2017) ) source_table
PIVOT
	(SUM(Quantity)
	FOR years IN ([2013],[2014],[2015],[2016],[2017])
	) pivot_table
*/

--19th
/*CREATE VIEW sales_per_group
AS 
SELECT *
FROM 
OPENQUERY([LAPTOP-KA4NATMO],N'SET FMTONLY OFF; exec SqlQuery')*/


/*
DECLARE @ColumnList VARCHAR(255)
SET @ColumnList = NULL

SELECT @ColumnList = COALESCE(@ColumnList +',', '') + QUOTENAME(StockGroupName)  
FROM Warehouse.StockGroups

DECLARE @SqlQuery NVARCHAR(MAX)
SET @SqlQuery =
	'SELECT years, '+@ColumnList+'
	FROM 
		(SELECT sg.StockGroupName, year(o.OrderDate) years, ol.Quantity
		FROM Sales.OrderLines ol
		JOIN Warehouse.StockItemStockGroups sisg
		ON ol.StockItemID = sisg.StockItemID
		JOIN Warehouse.StockGroups sg
		ON sisg.StockGroupID = sg.StockGroupID
		JOIN Sales.Orders o
		ON o.OrderID = ol.OrderID
		WHERE year(o.OrderDate) IN (2013, 2014, 2015, 2016, 2017) ) source_table
	PIVOT
		(SUM(Quantity)
		FOR StockGroupName IN ('+@ColumnList+')
		) pivot_table'

EXEC(CREATE VIEW sales_per_group AS SELECT * FROM @SqlQuery)
*/

--20th










