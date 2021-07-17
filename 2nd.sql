SELECT c.CustomerID, c.CustomerName
FROM Application.People p
JOIN Sales.Customers c
ON p.PersonID = c.PrimaryContactPersonID
where p.PhoneNumber = c.PhoneNumber AND c.BuyingGroupID IS NOT NULL

