SELECT s.CustomerID, s.CustomerName
FROM Application.People p
JOIN Sales.Customers s
ON p.PersonID = s.PrimaryContactPersonID
where p.PhoneNumber = s.PhoneNumber