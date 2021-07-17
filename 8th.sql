SELECT t2.StateProvinceName, AVG(processing_day) avg_process_day
FROM 

	(SELECT i.CustomerID, DATEDIFF(mm, o.OrderDate, i.ConfirmedDeliveryTime) processing_day
	FROM Sales.Invoices i
	JOIN Sales.Orders o
	ON o.OrderID = i.InvoiceID
	JOIN Sales.Customers c
	ON o.CustomerID = c.CustomerID) t1

JOIN

	(SELECT s.StateProvinceID, c.CustomerID, s.StateProvinceName
	FROM Sales.Customers c
	JOIN Application.Cities ci
	ON c.PostalCityID = ci.CityID
	JOIN Application.StateProvinces s
	ON ci.StateProvinceID = s.StateProvinceID) t2
ON t1.CustomerID = t2.CustomerID

GROUP BY t2.StateProvinceName
