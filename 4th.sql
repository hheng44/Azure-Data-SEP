SELECT sa.StockItemName , DATEPART(year,p.OrderDate) trans_year, SUM(s.Quantity) trans_num
 FROM [WideWorldImporters].[Warehouse].[StockItemTransactions] s
 JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] p
 ON s.PurchaseOrderID = p.PurchaseOrderID
 JOIN [WideWorldImporters].[Warehouse].[StockItems_Archive] sa
 ON sa.StockItemID = s.StockItemID
 WHERE DATEPART(year,p.OrderDate) = 2013
 GROUP BY sa.StockItemName , p.OrderDate