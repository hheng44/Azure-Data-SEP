SELECT c.CustomerID, c.CustomerName, o.OrderDate
FROM [WideWorldImporters].[Sales].[Customers_Archive] c
JOIN [WideWorldImporters].[Sales].[Orders] o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate < '2016-01-01' 

UNION

SELECT c.CustomerID, c.CustomerName, o.OrderDate
FROM [WideWorldImporters].[Sales].[Customers_Archive] c
JOIN [WideWorldImporters].[Sales].[Orders] o
ON c.CustomerID = o.CustomerID
WHERE not o.OrderDate >= '2016-01-01' 