SELECT sa.StockItemID,  SUM(s.Quantity) trans_num
 FROM [WideWorldImporters].[Warehouse].[StockItemTransactions] s
 JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] p
 ON s.PurchaseOrderID = p.PurchaseOrderID
 JOIN [WideWorldImporters].[Warehouse].[StockItems_Archive] sa
 ON sa.StockItemID = s.StockItemID
 WHERE DATEPART(year,p.OrderDate) = 2013
 GROUP BY sa.StockItemID
 ORDER BY sa.StockItemID


 SELECT pol.StockItemID, SUM(pol.OrderedOuters * pol.ReceivedOuters) total_purchase
 FROM Purchasing.PurchaseOrderLines pol
 JOIN Purchasing.PurchaseOrders po
 ON pol.PurchaseOrderID = po.PurchaseOrderID
 WHERE year(po.OrderDate) = 2013
 GROUP BY pol.StockItemID


 SELECT StockItemID, SUM(Quantity)
 FROM Warehouse.StockItemTransactions
 WHERE PurchaseOrderID IS NOT NULL AND year(TransactionOccurredWhen) = 2013
 GROUP BY StockItemID
 