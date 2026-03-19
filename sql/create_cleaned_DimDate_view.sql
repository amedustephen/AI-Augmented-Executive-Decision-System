DROP VIEW IF EXISTS dbo.vw_DimDate;
GO

CREATE VIEW dbo.vw_DimDate
AS
-- Cleansed DimDate Table --
SELECT 
    [DateKey]
    ,[FullDateAlternateKey] AS [Date]
    ,[DayNumberOfWeek] AS [DayNo]
    ,[EnglishDayNameOfWeek] AS [DayName]
    ,LEFT([EnglishDayNameOfWeek], 3) AS [DayShort]
    ,[WeekNumberOfYear] AS [WeekNo]
    ,[MonthNumberOfYear] AS [MonthNo]
    ,[EnglishMonthName] AS [Month]
    ,LEFT([EnglishMonthName], 3) AS [MonthShort]
    ,DATEFROMPARTS([CalendarYear], [MonthNumberOfYear], 1) AS [Start of Month]
    ,DATEFROMPARTS([CalendarYear], [MonthNumberOfYear], 1) AS [Year-Month]
    ,CONCAT(LEFT([EnglishMonthName], 3), ' ', [CalendarYear]) AS [Year_Month_Eng]
    ,[CalendarQuarter] AS [Quarter]
    ,CONCAT('Q', [CalendarQuarter]) AS [QuarterName]
    ,CONCAT('Q', [CalendarQuarter], '-', [CalendarYear]) AS [Quarter-Year]
    ,[CalendarYear] AS [Year]
    ,[FiscalQuarter]
    ,[FiscalYear]
    ,[FiscalSemester]
FROM [AdventureWorksDW2022].[dbo].[DimDate]
WHERE [CalendarYear] >= YEAR(GETDATE()) - 3;
GO