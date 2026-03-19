DROP VIEW IF EXISTS dbo.vw_FactInternetSales;

GO

CREATE VIEW dbo.vw_FactInternetSales AS

-- Cleansed FactInternetSales Table --
--SELECT TOP (1000)  --used before activating VIEW statement
SELECT TOP 100 PERCENT 
      [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      --,[PromotionKey]
      --,[CurrencyKey]
      ,[SalesTerritoryKey]
      ,[SalesOrderNumber]
      ,[OrderQuantity]  AS [Order Quantity]
      ,[UnitPrice] AS [Unit Price]
      --,[ExtendedAmount] AS [Extended Amount]
      --,[UnitPriceDiscountPct]
      --,[DiscountAmount]
      --,[ProductStandardCost] AS [Product Standard Cost]
      ,[TotalProductCost] AS [Total Product Cost]
      ,[SalesAmount] AS [Sales Amount]
      ,[SalesAmount] - [TotalProductCost] AS GrossProfit
FROM FactInternetSales
WHERE 
  LEFT (OrderDateKey, 4) >= YEAR(GETDATE()) -3 -- Ensures we only bring 3 years of data from today's date.
ORDER BY
  OrderDateKey ASC