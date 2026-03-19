/*******************************************************************************
CUSTOMER COHORT RETENTION ANALYSIS - MONTHLY VIEW (EXTENDED)
================================================================================
PURPOSE:
This view creates a comprehensive monthly customer cohort retention analysis 
that tracks customer behavior over time, including:
- Cohort retention rates (what % of original cohort remains active)
- New customer acquisition (first-time buyers each month)
- Returning customer activity (previously acquired customers making purchases)
- Generates a 24-month rolling cohort retention matrix
- Anchored to the last actual sale date in the database for data stability
- Adopts a LENIENT Lost definition using a configurable grace period (default = 2 months). 
  A customer is only flagged Lost if they are absent for MORE than @grace_period consecutive 
  months after their last purchase

WHAT IS A COHORT?
A cohort is a group of customers who made their first purchase in the same 
month, for the same product category, in the same country. This view tracks 
how many customers from each cohort return to make additional purchases in 
each subsequent month.

CUSTOMER CLASSIFICATIONS:
1.  NEW       – first purchase in the rolling window (month_number = 0)
2.  RETURNING – purchased last calendar month AND this month (consecutive, gap = 0 months)
3.  RECOVERED – purchased this month, last purchase was 1 to @grace_period months ago 
                (came back within the grace window)
4.  LOST      – purchased this month, but next purchase is more than @grace_period months away OR there
                is no next purchase in the window (month_number > 0 guard prevents New customers
                from being double-counted as Lost)

METHODOLOGY:
1. COHORT IDENTIFICATION: Identify each customer's first purchase month 
   (cohort_month) at the Customer × Category × Country level
2. ACTIVITY TRACKING: Track all months where cohort customers are active and 
   calculate month offset from their cohort start (Month 0, 1, 2, etc.)
3. NEW vs RETURNING: Classify each customer activity as new (Month 0) or 
   returning (Month 1+)
4. COHORT SIZING: Determine the original size of each cohort (Month 0 population)
5. RETENTION CALCULATION: Count how many customers from each cohort remain 
   active in subsequent months
6. PERCENTAGE CALCULATION: Calculate retention rate as a percentage of the 
   original cohort size

GRANULARITY:
- Cohort Month: The month when customers first purchased
- Activity Month: The actual calendar month of purchase activity
- Product Category: Individual categories + 'all' (rollup)
- Country: Individual countries + 'all' (rollup)
- Month Number: Months since cohort start (0, 1, 2, 3...)

KEY METRICS:
- new_customers: Count of first-time buyers in the activity month
- returning_customers: Count of repeat buyers in the activity month
- total_customers_month: Original cohort size (for retention calculation)
- retained_customers_month: Cohort members active in subsequent months
- percentage_month: Retention rate (retained / total)

EXAMPLE INTERPRETATION:
Activity Month: March 2023
- 50 new customers (their first purchase ever in Bikes/USA)
- 120 returning customers (purchased Bikes/USA before, buying again)
- From the Jan 2023 cohort (100 customers), 60 are still active (60% retention)

BUSINESS USE CASES:
- Track customer acquisition trends (new customers per month)
- Measure customer loyalty (returning customer rate)
- Identify which cohorts have the highest/lowest retention rates
- Compare retention patterns across product categories and countries
- Calculate Customer Lifetime Value (CLV) based on retention curves
- Forecast future revenue based on new + returning customer patterns
- Evaluate marketing campaign effectiveness on acquisition and retention

TABLES USED:
- vw_FactInternetSales: Transaction data
- vw_DimDate: Date dimension for temporal analysis
- vw_DimCustomer: Customer information (CustomerKey, Country)
- vw_DimProduct: Product information (ProductKey, ProductCategoryKey, ProductCategoryKey, Category, SubCategory)

OUTPUT COLUMNS:
- activity_month: Calendar month of purchase activity
- activity_year: Year of activity
- product_category: Product category or 'all' for rollup
- country: Country or 'all' for rollup
- new_customers: First-time buyers this month
- returning_customers: Repeat buyers this month
- total_active_customers: new_customers + returning_customers
- cohort_month: (For retention metrics) Original cohort month
- month_number: Months elapsed since cohort start
- total_customers_cohort: Original cohort size
- retained_customers_month: Cohort members still active
- retention_percentage: Retention rate (0.0000 to 1.0000)

NOTES:
- Uses CUBE for automatic category and country rollups
- A customer can be "new" in one category but "returning" in another
- Month 0 represents 100% retention (all cohort members are active)
- Retention typically decreases as month_number increases
- Sum of new_customers across all months = total unique customers acquired

AUTHOR: Amedu Paul Stephen
CREATED: February 2026
UPDATED: March 2026 - Added new/returning customer metrics
*******************************************************************************/


DROP VIEW IF EXISTS dbo.vw_CubeCustomerCohort;
GO

CREATE VIEW dbo.vw_CubeCustomerCohort AS

-- CTE 1: Dynamic Anchor. Finds the last transaction month and looks back 24 months.
WITH window_anchor AS (
    SELECT 
        DATEADD(month, -24, 
            DATEADD(month, DATEDIFF(month, 0, MAX(CAST(CAST(OrderDateKey AS VARCHAR) AS DATE))), 0)
        ) AS window_start
    FROM vw_FactInternetSales
),

-- CTE 2: Set the churn threshold (2 months gap = Lost).
lost_grace_months AS (
    SELECT 2 AS grace_months 
),

-- CTE 3: Identify 'Birth Month' per Customer/Category.
customer_cohort AS (
    SELECT 
        c.CustomerKey,
        c.Country,
        p.Category,
        MIN(DATEADD(mm, DATEDIFF(mm, 0, d.[Date]), 0)) AS cohort_month
    FROM vw_FactInternetSales s
    INNER JOIN vw_DimDate d ON s.OrderDateKey = d.DateKey
    INNER JOIN vw_DimCustomer c ON s.CustomerKey = c.CustomerKey
    INNER JOIN vw_DimProduct p ON s.ProductKey = p.ProductKey
    CROSS JOIN window_anchor wa
    WHERE d.[Date] >= wa.window_start
      AND s.CustomerKey IS NOT NULL
    GROUP BY c.CustomerKey, c.Country, p.Category
),

-- CTE 4: Monthly activity and revenue tracking.
customer_activities AS (
    SELECT DISTINCT
        cc.CustomerKey,
        cc.Country,
        cc.Category,
        cc.cohort_month,
        DATEADD(mm, DATEDIFF(mm, 0, d.[Date]), 0) AS month_num_lab,
        DATEDIFF(month, cc.cohort_month, d.[Date]) AS month_number,
        SUM(s.[Sales Amount]) OVER(PARTITION BY cc.CustomerKey, cc.Category, DATEDIFF(month, cc.cohort_month, d.[Date])) as monthly_sales
    FROM vw_FactInternetSales s
    INNER JOIN vw_DimDate d ON s.OrderDateKey = d.DateKey
    INNER JOIN vw_DimProduct p ON s.ProductKey = p.ProductKey
    INNER JOIN customer_cohort cc ON cc.CustomerKey = s.CustomerKey 
                                  AND cc.Category = p.Category
    CROSS JOIN window_anchor wa
    WHERE d.[Date] >= wa.window_start
),

-- CTE 5: Classify movements using LAG/LEAD.
customer_monthly_flags AS (
    SELECT 
        ca.*,
        LAG(ca.month_num_lab) OVER (PARTITION BY ca.CustomerKey, ca.Category ORDER BY ca.month_num_lab) AS prev_active_month,
        LEAD(ca.month_num_lab) OVER (PARTITION BY ca.CustomerKey, ca.Category ORDER BY ca.month_num_lab) AS next_active_month,
        DATEDIFF(month, LAG(ca.month_num_lab) OVER (PARTITION BY ca.CustomerKey, ca.Category ORDER BY ca.month_num_lab), ca.month_num_lab) AS months_since_prev,
        DATEDIFF(month, ca.month_num_lab, LEAD(ca.month_num_lab) OVER (PARTITION BY ca.CustomerKey, ca.Category ORDER BY ca.month_num_lab)) AS months_to_next,
        lgm.grace_months
    FROM customer_activities ca
    CROSS JOIN lost_grace_months lgm
    WHERE ca.month_number >= 0
),

-- CTE 6: Mutual exclusive status and Lost Flag.
customer_status_classified AS (
    SELECT 
        *,
        CASE 
            WHEN month_number = 0 THEN 'New'
            WHEN months_since_prev = 1 THEN 'Returning'
            WHEN months_since_prev > 1 OR (prev_active_month IS NULL AND month_number > 0) THEN 'Recovered'
            ELSE 'Unclassified'
        END AS customer_status,
        CASE 
            WHEN month_number > 0 AND (next_active_month IS NULL OR months_to_next > grace_months) THEN 1 
            ELSE 0 
        END AS lost_flag
    FROM customer_monthly_flags
),

-- CTE 7: Aggregation with Power BI subtotals.
retention_aggregated AS (
    SELECT 
        cohort_month,
        month_num_lab,
        month_number,
        CASE WHEN GROUPING(Category) = 1 THEN 'all' ELSE Category END AS product_category,
        CASE WHEN GROUPING(Country) = 1 THEN 'all' ELSE Country END AS country,
        COUNT(DISTINCT CustomerKey) AS retained_customers,
        SUM(monthly_sales) AS total_revenue,
        COUNT(DISTINCT CASE WHEN customer_status = 'New' THEN CustomerKey END) AS new_customers,
        COUNT(DISTINCT CASE WHEN customer_status = 'Returning' THEN CustomerKey END) AS returning_customers,
        COUNT(DISTINCT CASE WHEN customer_status = 'Recovered' THEN CustomerKey END) AS recovered_customers,
        SUM(lost_flag) AS lost_customers
    FROM customer_status_classified
    GROUP BY GROUPING SETS (
        (cohort_month, month_num_lab, month_number, Category, Country),
        (cohort_month, month_num_lab, month_number, Category),
        (cohort_month, month_num_lab, month_number)
    )
),

-- CTE 8: Cohort baseline sizes.
cohort_size AS (
    SELECT 
        cohort_month,
        CASE WHEN GROUPING(Category) = 1 THEN 'all' ELSE Category END AS category,
        CASE WHEN GROUPING(Country) = 1 THEN 'all' ELSE Country END AS country,
        COUNT(DISTINCT CustomerKey) AS total_customers_in_cohort
    FROM customer_cohort
    GROUP BY GROUPING SETS (
        (cohort_month, Category, Country),
        (cohort_month, Category),
        (cohort_month)
    )
)

-- FINAL SELECT.
SELECT 
    ra.cohort_month,
    YEAR(ra.cohort_month) AS cohort_year,
    ra.month_number,
    ra.month_num_lab,
    ra.product_category,
    ra.country,
    cs.total_customers_in_cohort AS total_customers_month,
    ra.retained_customers AS retained_customers_month,
    ra.total_revenue,
    ra.new_customers,
    ra.returning_customers,
    ra.recovered_customers,
    ra.lost_customers,
    CASE 
        WHEN ra.month_number = 0 THEN CAST(1.0000 AS DECIMAL(5,4))
        ELSE CAST(CAST(ra.retained_customers AS DECIMAL(18,4)) / NULLIF(cs.total_customers_in_cohort, 0) AS DECIMAL(5,4))
    END AS percentage_month
FROM retention_aggregated ra
LEFT JOIN cohort_size cs ON ra.cohort_month = cs.cohort_month 
                          AND ra.product_category = cs.category 
                          AND ra.country = cs.country
WHERE ra.cohort_month IS NOT NULL;
GO