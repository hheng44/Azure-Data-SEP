SELECT p.FullName, p.PhoneNumber, p.FaxNumber, s.PhoneNumber comp_phone, s.FaxNumber comp_fax
FROM Application.People p
JOIN Purchasing.Suppliers s
ON p.PersonID = s.LastEditedBy

UNION

SELECT p.FullName, p.PhoneNumber, p.FaxNumber, s.PhoneNumber comp_phone, s.FaxNumber comp_fax
FROM Application.People p
left JOIN Sales.Customers s
ON p.PersonID = s.LastEditedBy
left JOIN Sales.CustomerCategories a
ON p.PersonID = a.LastEditedBy
WHERE a.CustomerCategoryName != 'Agent'
