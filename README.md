# Ecommerce-sales-analysis-sql-excel
SQL and Excel analysis of an E-commerce dataset to explore sales, payments, customer behavior, and delivery performance.

**Author:** Mohammed Khafagy  
**Role:** Junior Data Analyst  
**Tools:** SQL Server, Excel (Power Pivot, Pivot Tables, Slicers)

---

## Project Overview

This project provides a comprehensive analysis of e-commerce sales, payments, and delivery data.  
The workflow involved:

1. **Data Extraction & Cleaning:** Using SQL to remove duplicates, correct invalid dates, handle missing values, and ensure logical consistency.  
2. **Data Modeling:** Building a **Power Pivot model** with One-to-Many relationships to enable efficient aggregation and dashboarding.  
3. **Interactive Dashboard:** Developing an **Excel dashboard** to monitor KPIs, regional performance, payment methods, seasonal trends, and delivery efficiency.

The goal was to turn raw data into actionable insights to support business decision-making.

---

## Project Structure
Ecommerce-sales-analysis-sql-excel/
│
├─ Data/
│ ├─ df_Orders.csv
│ ├─ df_Customers.csv
│ ├─ df_OrderItems.csv
│ ├─ df_Products.csv
│ └─ df_Payments.csv
│
├─ SQL/
│ ├─ Cleaning/
│ │ └─ cleaning_queries.sql # Scripts for data cleaning and validation
│ ├─ Views/
│ │ └─ views_queries.sql # Scripts creating SQL views for analysis
│
├─ DashBoard/
│ └─ Ecommerce_Dashboard.png # Screenshot of interactive Excel dashboard
│
└─ README.md

---

## Key Insights

- **Sales vs Payments Gap:** Total sales exceeded **$34.4M**, while total payments were **$23.9M**, caused by incomplete installments and voucher usage.  
- **Delivery Efficiency:** 99% of orders delivered successfully, with an average delivery duration of **5 days**.  
- **Regional Performance:** São Paulo accounted for over **$14M** in sales, highlighting concentration of customers.  
- **Payment Methods:** Over 70% of payments via **credit card**, showing dependency on a single method.  
- **Seasonal Trends:** Peak sales occur in December, reflecting seasonal shopping behavior.

---

## Dashboard Overview

The Excel dashboard provides a **dynamic interactive view** of:

- Total sales, total payments, and sales-payment gaps.  
- Order tracking: delivered, estimated delivery, and efficiency indicators.  
- Regional analysis: sales by state and city.  
- Product categories: top 10 categories with "Other" grouping.  
- Payment methods: visualizing dependency on credit card vs. other methods.  
- Seasonal trends: monthly and seasonal sales patterns.  
- Interactive filters: by customer type, order status, region, and category.

> Users can drill down into the data, compare performance, and identify trends to support strategic decisions.

---

## How to Use

1. Load CSV files from `Data/` into Excel Power Pivot.  
2. Apply relationships as per the original data model.  
3. Review SQL scripts in `SQL/` to understand cleaning, validation, and view logic.
4.  Build your dashboard journy.

---

## Skills Demonstrated

- **SQL:** Data cleaning, validation, view creation, aggregation  
- **Excel:** Pivot Tables, Power Pivot, Slicers, interactive dashboarding  
- **Data Analysis:** KPI computation, trend and gap analysis, regional insights  
- **Data Modeling:** Establishing One-to-Many relationships for efficient reporting  

---

## Notes

- CSV files include all necessary tables for reproducing the dashboard.  
- Dashboard screenshot included for visualization.  
- All transformations were performed using SQL and Excel; no additional programming tools were required.
