# Olist E-Commerce Sales Analysis

## Overview

This project analyses sales performance for the Olist Brazilian e-commerce marketplace using PostgreSQL and Excel. The aim was to identify which product categories and regions generate the most revenue and to present the results in an interactive dashboard.

## Dataset

- **Source:** Olist Brazilian E-Commerce Public Dataset (Kaggle)
- About 100,000 orders across multiple related tables
- Data covers the period from 2016 to 2018

## Tools Used

- **PostgreSQL** for data cleaning, joins, and analysis
- **DBeaver** for running queries and exporting data
- **Microsoft Excel** for PivotTables, charts, slicers, and the final dashboard

## Dashboard Preview

### Final Dashboard
![Final Dashboard](Screenshots/Final%20Dashboard.png)
### Slicer Interaction
![Dashboard preview](Screenshots/Dashboard%20preview.gif)
*Year and month slicers filtering the dashboard's KPI and monthly chart live.*

## What I Did

**1. Created the database tables**

I imported each CSV file into its own table. I first created the tables and assigned data types manually instead of relying on the import wizard. ZIP codes were stored as VARCHAR so that leading zeros would not be lost, while others were assigned BIGINT for IDs and TIMESTAMP for dates.

**2. Data Inspection**

Before cleaning the data, I checked for missing values, duplicates, and inconsistent category values.

I used `COUNT()` to compare the rows and look for NULL values, and also used a `HAVING COUNT(*) > 1` variation to check for duplicates among single columns and columns that go together, e.g. `(order_id, payment_sequential)`.

I found:
- No duplicates found in the dataset
- Missing delivery dates were mostly linked to cancelled or unavailable orders
- Some products were missing category information or physical dimensions

**3. Cleaned the data**

I created clean views for the raw tables and used `COALESCE` to label missing product categories as "uncategorised" instead of deleting those rows. I also created a view that joined the English category names to the products table as `products_english`.

**4. Built analysis views**

I then joined the order and order item tables, removed cancelled and unavailable orders, and created views for:

- Sales per category
- Sales per customer region
- Sales per seller region
- Sales per category and region
- Monthly sales

One useful lesson from this step was catching a filter issue where I used "cancelled" instead of "canceled." The query ran successfully, but it was not filtering any rows, which reminded me to always check the results rather than assuming a query is correct because it runs.

**5. Created the Excel dashboard**

I exported the analysis views to Excel and built a dashboard with KPI cards, charts, and Year/Month slicers.

I decided to limit the charts to the top 15 categories, as there were too many categories and it was affecting how the chart looked.

## Key Findings

- Health & Beauty was the highest-revenue category.
- São Paulo (SP) generated the largest share of both customer demand and seller supply.
- Revenue grew steadily through 2017 and then levelled off during 2018.
- The final month in the dataset was incomplete, so it was excluded from the trend chart.

## Project Files

- `SQL/raw_to_clean.sql` — table creation, data checks, and cleaning
- `SQL/views_for_calculations.sql` — analysis views
- `excel/Olist sales analysis.xlsx` — final dashboard

## Limitations

- Product categories were originally in Portuguese and were translated using the provided lookup table.
- A small number of products had missing category or dimension data, so they were excluded from calculations that required those fields.
