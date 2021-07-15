SELECT DISTINCT sa.StockItemID, sa.StockItemName, st.TransactionOccurredWhen
FROM [WideWorldImporters].[Warehouse].[StockItems_Archive] sa
JOIN [WideWorldImporters].[Warehouse].[StockItemTransactions] st
ON sa.StockItemID = st.StockItemID
JOIN [WideWorldImporters].[Application].[People] p
ON p.PersonID = st.LastEditedBy
JOIN [WideWorldImporters].[Application].[StateProvinces] sp
ON p.PersonID = sp.LastEditedBy
WHERE sp.StateProvinceName not in ('Alabama', 'Georgia ') and DATEPART(year, st.TransactionOccurredWhen) = '2014'
ORDER BY st.TransactionOccurredWhen