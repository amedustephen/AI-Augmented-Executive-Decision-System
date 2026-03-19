# AI-Augmented Executive Decision Intelligence Platform  
### Enterprise Data Warehousing • Executive BI • AI-Integrated Analytics

---

## Overview

This project demonstrates how to design and deliver a **board-ready executive analytics system** — not just a dashboard.

Using the AdventureWorksDW2022 dataset as a realistic enterprise scenario, the solution simulates a mid-sized organization seeking to:

- Improve executive visibility into performance
- Align actuals with planning data
- Reduce manual interpretation of reports
- Introduce AI-assisted decision support
- Strengthen trust in metrics through governed modeling

The result is a scalable, performance-aware analytics architecture that bridges **data engineering, business intelligence, and AI integration**.

---

## Business Context

Organizations that reach scale often experience:

- Fragmented reporting across teams  
- Budget data disconnected from operational systems  
- Over-reliance on analysts to interpret dashboards  
- Slow decision cycles due to metric ambiguity  

This project addresses those challenges by:

- Centralizing business logic in SQL
- Enforcing strict grain alignment
- Building a clean star schema
- Delivering KPI-driven executive pages
- Integrating AI narratives grounded in governed measures

---

## Dataset

**Source:** AdventureWorksDW2022 (SQL Server)

**Modeled Components:**

- Sales fact table (line-level grain)
- Budget fact table (category–month grain)
- Conformed dimensions (Date, Product, Customer, Geography)
- Persisted cohort base table
- Monthly customer retention cube

All metrics are sourced from SQL views to prevent logic drift.

---

## Architecture

### 1. Enterprise Data Layer (SQL Server)

- Star schema design
- Business logic centralized in views
- Indexed cohort base table for performance
- Data quality validation (null and negative offset checks)
- Month-0 retention guardrail (always 100%)

### 2. Semantic Layer (Power BI)

- Single-direction relationships
- Explicit grain definitions
- Thin, performance-safe DAX measures
- No business logic embedded in visuals

### 3. AI Insight Layer

- Smart Narrative integration
- Variance-driven explanations
- KPI-aligned executive summaries

AI enhances decision clarity — it does not replace governed metrics.

---

## Executive Dashboard

Each page answers a single executive question.

---

### Executive Command Center  
**What is happening right now?**

![Executive Command Center](images/executive_command_center.png)

- Revenue, Profit, Margin, Orders
- Budget vs Actual
- MoM & YoY growth
- AI-generated executive summary

---

### Performance vs Plan  
**Where are we missing or beating expectations?**

![Performance vs Plan](images/performance_vs_plan.png)

- Category-level variance
- Time-based budget analysis
- Variance waterfall
- Financial accountability view

---

### Regional & Product Intelligence  
**What is driving growth and profitability?**

![Regional and Product Intelligence](images/regional_product_analysis.png)

- Revenue vs Margin scatter
- Regional growth ranking
- Profit contribution analysis
- Margin erosion detection

---

### Customer Value & Segmentation  
**Who actually drives the business?**

![Customer Segmentation](images/customer_segmentation.png)

- High-value customer identification
- Average revenue per customer
- Segment-level contribution
- Demographic overlays

---

### Cohort & Retention Analysis  
**Are customers staying — and why?**

![Cohort Analysis](images/cohort_analysis.png)

- Monthly cohort matrix
- Retention decay curve
- Category-level retention
- Guardrailed Month-0 baseline

Cohort logic is pre-aggregated in SQL for performance and integrity.

---

### AI Executive Brief  
**Tell me the story.**

![AI Executive Brief](images/ai_executive_brief.png)

- KPI movement explanation
- Variance drivers
- Risk and opportunity flags
- Narrative aligned with governed measures

---

## Results & Impact (Simulated Enterprise Outcomes)

Although built on sample data, the architecture reflects real deployment patterns.

In a live environment, this solution would typically:

- Reduce reporting-to-decision time by 30–50%
- Eliminate metric inconsistencies across departments
- Improve budget accountability
- Surface profit drivers instead of volume illusions
- Increase executive adoption of analytics tools

Most importantly, it demonstrates how analytics should scale with the business — structurally, not visually.

---

## Key Design Principles

- Grain alignment before visualization  
- Single-direction filtering only  
- Pre-aggregation for performance  
- AI grounded in validated metrics  
- Business logic belongs in SQL  

---

## How to Run

### 1. Database Setup
- Restore AdventureWorksDW2022
- Execute SQL scripts in `/sql` directory
  - Fact and dimension views
  - Cohort base table
  - Retention cube view

### 2. Budget Integration
- Load budget Excel file into staging table
- Create `vw_FactBudget`

### 3. Power BI
- Open `.pbix` file
- Update SQL connection
- Refresh dataset

Optional:
- Enable incremental refresh
- Materialize retention results for large datasets

---

## About This Project

This repository showcases capabilities across:

- Enterprise data warehousing
- Executive BI architecture
- Performance-safe DAX modeling
- Cohort-based retention analytics
- AI-integrated reporting
- Governance-first design

It reflects how I approach analytics engagements:  
**Structure first. Metrics second. Visualization last.**

---

## License

Demonstration and portfolio purposes.
