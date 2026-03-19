DROP VIEW IF EXISTS dbo.vw_DimSalesTerritory;

GO

CREATE VIEW dbo.vw_DimSalesTerritory AS

-- Cleansed DimSalesTerritory Table --
SELECT 
      [SalesTerritoryKey]
      ,[SalesTerritoryRegion] AS Region
      ,[SalesTerritoryCountry] AS Country
      ,[SalesTerritoryGroup] AS [Group]
FROM DimSalesTerritory
WHERE SalesTerritoryCountry <> 'NA';