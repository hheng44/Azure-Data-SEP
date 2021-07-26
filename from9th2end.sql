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

----14th
/*
SELECT  t2.CityName, t2.StateProvinceName, t2.CountryName, COALESCE(t1.StockItemID, 'no sales') StockItemID, COALESCE(s.StockItemName,'no sales') StockItemName, COALESCE(t1.total_received, 'no sales') total_received_num
FROM 
	(
		SELECT b.DeliveryCityID, StockItemID, total_received
		FROM
			(SELECT DeliveryCityID, StockItemID, total_received, RANK() OVER (PARTITION BY DeliveryCityID ORDER BY total_received DESC) ranks
			FROM 
				(SELECT c.DeliveryCityID, il.StockItemID, SUM(il.Quantity) total_received
				FROM Sales.InvoiceLines il
				JOIN Sales.Invoices i
				ON i.InvoiceID = il.InvoiceID
				JOIN Sales.Customers c
				ON i.CustomerID = c.CustomerID
				WHERE DATEPART(yy, i.ConfirmedDeliveryTime) = '2016' and JSON_VALUE (ReturnedDeliveryData, '$.Events[1].Status') IS NOT NULL
				GROUP BY c.DeliveryCityID, il.StockItemID) a )b
		WHERE b.ranks = 1
	) t1

RIGHT JOIN

	(SELECT c.CityName, co.CountryName, sp.StateProvinceName, c.CityID
	FROM Application.StateProvinces sp
	JOIN Application.Countries co
	ON sp.CountryID = co.CountryID AND co.CountryName = 'United States'
	JOIN Application.Cities c
	ON sp.StateProvinceID = c.StateProvinceID) t2

ON t1.DeliveryCityID = t2.CityID
JOIN Warehouse.StockItems s
ON t1.StockItemID = s.StockItemID
*/





--15th
/*
SELECT OrderID
FROM Sales.Invoices
WHERE JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Comment') IS NOT NULL
*/

--16th
/*
SELECT StockItemName, JSON_VALUE(CustomFields, '$.CountryOfManufacture') CountryOfManufacture
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
/*
CREATE VIEW sales_per_group
AS
SELECT  Years, [T-Shirts],[USB Novelties],[Packaging Materials],
							[Clothing],[Novelty Items],[Furry Footwear],[Mugs],
							[Computing Novelties],[Toys]
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
	FOR StockGroupName IN ([T-Shirts],[USB Novelties],[Packaging Materials],
							[Clothing],[Novelty Items],[Furry Footwear],[Mugs],
							[Computing Novelties],[Toys])
	) pivot_table

*/


--dynamic pivot but fail to create view

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

EXEC(@SqlQuery)
*/

--20th

----CREATE FUNCTION total_order(@OrderID INT)
--ALTER FUNCTION total_order(@OrderID INT)
--RETURNS INT
--AS 

--BEGIN
--	DECLARE @ret INT
--	SELECT @ret = ol.Quantity *ol.UnitPrice
--	FROM Sales.Orders o
--	JOIN Sales.OrderLines ol
--	ON o.OrderID = ol.OrderID
--	WHERE o.OrderID = @OrderID
--		IF (@ret IS NULL)
--			SET @ret = 0
--	RETURN @ret
--END


--SELECT i.InvoiceID, o.OrderID, dbo.total_order(o.OrderID) order_total
--FROM Sales.Orders o
--JOIN Sales.Invoices i
--ON o.OrderID = i.OrderID


--21th
/*
--CREATE PROCEDURE dbo.order_info
ALTER PROCEDURE dbo.order_info
@OrderDate Date

AS
BEGIN
	SET NOCOUNT ON
	--SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO table_of_21
			SELECT * FROM 
					(SELECT  o.OrderID, o.CustomerID, o.OrderDate, SUM(ol.Quantity*ol.UnitPrice) order_total
					FROM Sales.Orders o
					JOIN Sales.OrderLines ol
					ON o.OrderID = ol.OrderID
					WHERE o.OrderDate = @OrderDate
					GROUP BY  o.OrderID, o.CustomerID, o.OrderDate
					) t1
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage
		--IF ERROR_NUMBER() = 2627
		--	THROW 50000 , 'Duplicate date in DB', 1
		--	ROLLBACK TRANSACTION
		--IF ERROR_NUMBER() = 515
		--	THROW 50001, 'NO order at that date', 1
		--	ROLLBACK TRANSACTION
	END CATCH
END


--CREATE TABLE table_of_21 
--(OrderID INT,
--CustomerID INT,
--OrderDate DATE,
--OrderTotal INt
--)

DELETE 
FROM table_of_21

SELECT *
FROM table_of_21


EXEC dbo.order_info @OrderDate = '2013-01-01'
EXEC dbo.order_info @OrderDate = '2014-01-01'
EXEC dbo.order_info @OrderDate = '2015-01-01'
EXEC dbo.order_info @OrderDate = '2016-01-01'
EXEC dbo.order_info @OrderDate = '2017-01-01'
*/



--22th
/*
CREATE SCHEMA ods 
	CREATE TABLE ods.StockItem
	(StockItemID INT,
	StockItemName NVARCHAR(100),
	SupplierID INT,
	ColorID INT,
	UnitPackageID INT,
	OuterPackageID INT,
	Brand NVARCHAR(50),
	Size NVARCHAR(20),
	LeadTimeDays INT,
	QuantityPerOuter INT,
	IsChillerStock BIT,
	Barcode NVARCHAR(50),
	TaxRate DECIMAL(18,3),
	UnitPrice DECIMAL(18,2),
	RecommendedRetailPrice DECIMAL(18,2),
	TypicalWeightPerUnit DECIMAL(18,3),
	MarketingComments NVARCHAR(MAX),
	InternalComments NVARCHAR(MAX), 
	CountryOfManufacture NVARCHAR(MAX), 
	Ranges DATETIME2, 
	Shelflife DATETIME2 ,
	CONSTRAINT pk_stock PRIMARY KEY (StockItemID)
	)


--DELETE FROM ods.StockItem

INSERT INTO ods.StockItem
SELECT StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode, TaxRate,
UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit,MarketingComments, InternalComments, 
JSON_VALUE(CustomFields, '$.CountryOfManufacture'), ValidFrom, ValidTo 
FROM Warehouse.StockItems
*/

--23th
/*
CREATE PROCEDURE dbo.order_info_wipe
--ALTER PROCEDURE dbo.order_info_23
@OrderDate Date

AS
BEGIN
	SET NOCOUNT ON
	--SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION
			DELETE 
			FROM table_of_21
			WHERE OrderDate < @OrderDate
			
			INSERT INTO table_of_21
			SELECT * FROM 
					(SELECT  o.OrderID, o.CustomerID, o.OrderDate, SUM(ol.Quantity*ol.UnitPrice) order_total
					FROM Sales.Orders o
					JOIN Sales.OrderLines ol
					ON o.OrderID = ol.OrderID
					WHERE o.OrderDate > @OrderDate AND o.OrderDate < DATEADD(day, 7, @OrderDate)
					GROUP BY  o.OrderID, o.CustomerID, o.OrderDate
					) t1
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage
	END CATCH
END

EXEC dbo.order_info_wipe @OrderDate = '2014-01-01'

*/


--SELECT *
--FROM table_of_21

--DELETE 
--FROM table_of_21
--WHERE OrderDate < '2014-01-01'
			
--INSERT INTO table_of_21
--SELECT * FROM 
--		(SELECT  o.OrderID, o.CustomerID, o.OrderDate, SUM(ol.Quantity*ol.UnitPrice) order_total
--		FROM Sales.Orders o
--		JOIN Sales.OrderLines ol
--		ON o.OrderID = ol.OrderID
--		WHERE o.OrderDate BETWEEN '2014-01-02' AND DATEADD(day, 7, '2014-01-01')
--		GROUP BY  o.OrderID, o.CustomerID, o.OrderDate
--		) t1


--24th
/*
DECLARE @json NVARCHAR(MAX)
SET @json = N'[
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":[6,7],
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
      },
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":7,
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-025",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
      }
   ]'




--DECLARE @count INT
--SET @count = 1

--WHILE (@count<=2)
--BEGIN


SELECT *
FROM OPENJSON (@json)
	WITH 
	(
		StockItemName NVARCHAR(100) '$.StockItemName',
		SupplierID INT '$.Supplier',
		UnitPackageID INT '$.UnitPackageId',
		OuterPackageId NVARCHAR(MAX) '$.OuterPackageId', 
		--OuterPackageID INT '$.OuterPackageId[1]' ,
		Brand NVARCHAR(50) '$.Brand',
		LeadTimeDays INT '$.LeadTimeDays',
		QuantityPerOuter INT '$.QuantityPerOuter',
		TaxRate DECIMAL(18,2) '$.TaxRate',
		UnitPrice DECIMAL(18,3) '$.UnitPrice',
		RecommendedRetailPrice DECIMAL(18,2) '$.RecommendedRetailPrice',
		TypicalWeightPerUnit DECIMAL(18,3) '$.TypicalWeightPerUnit',
		CountryOfManufacture NVARCHAR(50) '$.CountryOfManufacture',
		Ranges NVARCHAR(50) '$.Range',
		OrderDate DATETIME '$.OrderDate',
		DeliveryMethod NVARCHAR(50) '$.DeliveryMethod',
		ExpectedDeliveryDate DATETIME '$.ExpectedDeliveryDate',
		SupplierReference NVARCHAR(100) '$.SupplierReference'
	)
OUTER APPLY OPENJSON(OuterPackageId)
*/





/*
INSERT INTO Warehouse.StockItems
SELECT *
FROM OPENJSON (@json)
	WITH 
	(
		StockItemName NVARCHAR(100) '$.StockItemName',
		SupplierID INT '$.Supplier',
		UnitPackageID INT '$.UnitPackageId',
		OuterPackageId NVARCHAR(MAX) '$.OuterPackageId' AS JSON,
		--OuterPackageID INT '$.OuterPackageId[1]' ,
		Brand NVARCHAR(50) '$.Brand',
		LeadTimeDays INT '$.LeadTimeDays',
		QuantityPerOuter INT '$.QuantityPerOuter',
		TaxRate DECIMAL(18,2) '$.TaxRate',
		UnitPrice DECIMAL(18,3) '$.UnitPrice',
		RecommendedRetailPrice DECIMAL(18,2) '$.RecommendedRetailPrice',
		TypicalWeightPerUnit DECIMAL(18,3) '$.TypicalWeightPerUnit',
		CountryOfManufacture NVARCHAR(50) '$.CountryOfManufacture',
		Ranges NVARCHAR(50) '$.Range',
		OrderDate DATETIME '$.OrderDate',
		DeliveryMethod NVARCHAR(50) '$.DeliveryMethod',
		ExpectedDeliveryDate DATETIME '$.ExpectedDeliveryDate',
		SupplierReference NVARCHAR(100) '$.SupplierReference'
	)
OUTER APPLY OPENJSON (OuterPackageId)
	WITH (OuterPackageID INT '$')
*/



--25th
/*
SELECT years =  Years, 
		Tshirt = [T-Shirts],
		USBNovlties = [USB Novelties],
		PackageMaterials = [Packaging Materials],
		Clothing = [Clothing],
		NoveltyItem = [Novelty Items],
		FurryFootwear = [Furry Footwear],
		Mugs = [Mugs],
		ComputingNovlties = [Computing Novelties],
		Toys = [Toys]
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
	FOR StockGroupName IN ([T-Shirts],[USB Novelties],[Packaging Materials],
							[Clothing],[Novelty Items],[Furry Footwear],[Mugs],
							[Computing Novelties],[Toys])
	) pivot_table
FOR JSON AUTO
*/

--26th
/*
SELECT  Years, [T-Shirts],[USB Novelties],[Packaging Materials],
							[Clothing],[Novelty Items],[Furry Footwear],[Mugs],
							[Computing Novelties],[Toys]
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
	FOR StockGroupName IN ([T-Shirts],[USB Novelties],[Packaging Materials],
							[Clothing],[Novelty Items],[Furry Footwear],[Mugs],
							[Computing Novelties],[Toys])
	) pivot_table
FOR XML AUTO
*/

--27th

CREATE PROCEDURE ods.confirm_delivery
@InvoiceDate DATE

AS
BEGIN

	INSERT INTO ods.ConfirmedDeviveryJson (id, dates, value)
	VALUES ()
	SELECT *
	FROM Sales.Invoices i
	JOIN Sales.InvoiceLines il
	ON i.InvoiceID = il.InvoiceID
	WHERE i.CustomerID = 1 and i.InvoiceDate = @InvoiceDate
	FOR JSON AUTO


END





--CREATE TABLE ods.ConfirmedDeviveryJson (
--	id INT,
--	dates DATE,
--	value NVARCHAR(MAX)
--	CONSTRAINT delivery_id PRIMARY KEY (id)
--)





--SELECT *
--FROM Sales.Invoices i
--JOIN Sales.InvoiceLines il
--ON i.InvoiceID = il.InvoiceID
--WHERE i.CustomerID = 1 


DECLARE @row_count INT, @current_row INT
 SELECT @row_count= COUNT(*)
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
ON i.InvoiceID = il.InvoiceID
WHERE i.CustomerID = 1 

SET @current_row = 0

WHILE @row_count > 1
BEGIN
	SELECT *
	FROM Sales.Invoices i
	JOIN Sales.InvoiceLines il
	ON i.InvoiceID = il.InvoiceID
	ORDER BY i.InvoiceID
	OFFSET @current_row ROWS
	FETCH FIRST 1 ROWS ONLY
	FOR JSON AUTO

	INSERT ods.ConfirmedDeviveryJson
	SELECT JSON_VALUE()

	SET @current_row = @current_row + 1
	SET @row_count = @row_count - 1
END




--DECLARE @id INT, @dates DATE, @values NVARCHAR(MAX) 

--DECLARE record_cursor CURSOR FOR 
--SELECT *
--FROM Sales.InvoiceLines il
--JOIN Sales.Invoices i 
--ON il.InvoiceID = i.InvoiceID
--WHERE i.CustomerID = 1

--OPEN record_cursor

--FETCH NEXT FROM record_cursor
--INTO 


/*
SELECT INTO ods.temp_table
SELECT *
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
ON i.InvoiceID = il.InvoiceID
ORDER BY i.InvoiceID
OFFSET 0 ROWS
FETCH FIRST 1 ROWS ONLY
FOR JSON AUTO




CREATE TABLE #personAW(
	PersonID INT PRIMARY KEY NOT NULL,
	Fullname NVARCHAR(50) NOT NULL,
	PreferredName NVARCHAR(100) NOT NULL,
	IsPermittedToLogon bit NOT NULL,
	LogoName NVARCHAR(50),
	IsExternalLogonProvider bit NOT NULL,
	HashedPassword VARBINARY(MAX),
	IsSystemUser BIT NOT NULL,
	IsEmployee BIT NOT NULL,
	IsSalesperson BIT NOT NULL,
	UserPreferences NVARCHAR(MAX),
	PhoneNumber NVARCHAR(20), 
	FaxNumber NVARCHAR(20),
	EmailAddress NVARCHAR(20),
	Photo VARBINARY(MAX),
	CustomFields VARCHAR(MAX),
	OtherLanguages NVARCHAR(MAX),
	LastEditedBy INT NOT NULL,
	ValidFrom DATETIME2 NOT NULL,
	ValidTo DATETIME2 NOT NULL
)
GO
*/


