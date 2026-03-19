SELECT
    MIN(YEAR(OrderDate)),
    MAX(YEAR(OrderDate))
FROM FactInternetSales;

SELECT
    MIN(YEAR(FullDateAlternateKey)),
    MAX(YEAR(FullDateAlternateKey))
FROM DimDate;

SELECT TOP 100 *
FROM FactInternetSales
ORDER BY OrderDate DESC;

