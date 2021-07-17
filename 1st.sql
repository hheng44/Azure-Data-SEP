SELECT p.FullName, p.PhoneNumber, p.FaxNumber, s.PhoneNumber comp_phone, s.FaxNumber comp_fax
FROM [WideWorldImporters].[Application].[People] p
JOIN [WideWorldImporters].[Purchasing].[Suppliers] s
ON p.PersonID = s.LastEditedBy

UNION ALL

SELECT p.FullName, p.PhoneNumber, p.FaxNumber, s.PhoneNumber comp_phone, s.FaxNumber comp_fax
FROM [WideWorldImporters].[Application].[People] p
JOIN [WideWorldImporters].[Sales].[Customers] s
ON p.PersonID = s.LastEditedBy
JOIN [WideWorldImporters].[Sales].[CustomerCategories] a
ON p.PersonID = a.LastEditedBy
WHERE a.CustomerCategoryName != 'Agent'
