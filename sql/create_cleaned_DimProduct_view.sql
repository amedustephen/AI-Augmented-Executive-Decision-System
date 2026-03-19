DROP VIEW IF EXISTS dbo.vw_DimProduct;

GO

CREATE VIEW dbo.vw_DimProduct AS

-- Cleansed DimProduct Table --
--SELECT TOP (1000)  --used before activating VIEW statement
SELECT TOP 100 PERCENT
  p.[ProductKey] 
  ,p.[ProductAlternateKey] AS [Product SKU] 
  ,p.[EnglishProductName] AS [Product Name] 
  ,P.StandardCost AS [Standard Cost]
  ,p.[Color] AS [Product Color] 
  ,p.ListPrice AS [List Price]
  ,p.Style AS [Product Style]
  ,p.[ModelName] AS [Product Model]
  ,p.ProductSubcategoryKey
  ,ps.EnglishProductSubcategoryName AS SubCategory -- Joined in from Sub Category Table
  ,ps.ProductCategoryKey
  ,pc.EnglishProductCategoryName AS Category -- Joined in from Category Table 
  ,P.LargePhoto AS [Product Photo]
  ,ISNULL (p.Status, 'Outdated') AS [Product Status] 
FROM 
  DimProduct as p
  LEFT JOIN DimProductSubcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey 
  LEFT JOIN DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey 
order by 
  p.ProductKey asc
