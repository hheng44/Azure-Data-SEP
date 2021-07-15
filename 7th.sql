SELECT sa.StateProvinceName, AVG(DATEDIFF(day, o.OrderDate, ConfirmedDeliveryTime))
FROM [WideWorldImporters].[Sales].[Orders] o
JOIN [WideWorldImporters].[Sales].[Invoices] i
ON o.OrderID = i.OrderID
JOIN [WideWorldImporters].[Application].[People] p
ON o.LastEditedBy = p.PersonID
JOIN [WideWorldImporters].[Application].[StateProvinces_Archive] sa
ON o.LastEditedBy = p.PersonID
GROUP BY sa.StateProvinceName

