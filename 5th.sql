SELECT StockItemID, StockItemName
FROM [WideWorldImporters].[Warehouse].[StockItems_Archive] 
WHERE LEN(SearchDetails) >= 10