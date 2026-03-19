DROP VIEW IF EXISTS dbo.vw_DimCustomer;

GO

CREATE VIEW dbo.vw_DimCustomer AS

-- Cleansed DimCustomer Table --
--SELECT TOP (1000)  --used before activating VIEW statement
SELECT TOP 100 PERCENT 
      c.CustomerKey
      --,c.GeographyKey
      --,c.CustomerAlternateKey
      --,c.Title
      --,c.FirstName
      --,c.MiddleName
      --,c.LastName
      ,c.FirstName + ' ' + c.LastName AS [Full Name]
      ,c.BirthDate
      --,c.Gender
      ,CASE c.gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' END AS Gender
      ,c.YearlyIncome AS AnnualIncome
      ,c.TotalChildren
      ,c.EnglishEducation AS EducationLevel
      ,c.HouseOwnerFlag AS HomeOwner
      ,c.datefirstpurchase AS DateFirstPurchase
      ,g.city AS [City] -- Joined in Customer City from Geography Table
      ,g.stateprovincename AS [State-Province]
      ,st.SalesTerritoryCountry AS Country
      ,st.SalesTerritoryRegion AS Region
      ,g.postalcode AS [Postal Code]
FROM 
  DimCustomer as c
  LEFT JOIN DimGeography AS g ON g.geographykey = c.geographykey 
  LEFT JOIN DimSalesTerritory AS st ON g.SalesTerritoryKey = st.SalesTerritoryKey
ORDER BY 
  CustomerKey ASC -- Ordered List by CustomerKey