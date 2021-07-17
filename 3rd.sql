SELECT t1.CustomerName
FROM 
	(SELECT c.CustomerName
	FROM [WideWorldImporters].[Sales].[Customers_Archive] c
	JOIN [WideWorldImporters].[Sales].[Orders] o
	ON c.CustomerID = o.CustomerID
	WHERE o.OrderDate < '2016-01-01' 
	GROUP BY c.CustomerName) t1

JOIN

	(SELECT c.CustomerName
	FROM [WideWorldImporters].[Sales].[Customers_Archive] c
	JOIN [WideWorldImporters].[Sales].[Orders] o
	ON c.CustomerID = o.CustomerID
	WHERE not o.OrderDate >= '2016-01-01' 
	GROUP BY c.CustomerName) t2
ON t1.CustomerName = t2.CustomerName


--I think on t1 or t2 is enough though