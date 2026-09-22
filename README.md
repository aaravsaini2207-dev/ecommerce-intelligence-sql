# E-commerce Intelligence — Advanced SQL Analytics

**Advanced MySQL analysis of the Olist Brazilian e-commerce dataset, focused on customer value, retention, churn indicators, revenue trends, discount exposure, and seller/freight analysis.**

> This repository is an **experimental SQL analytics workspace**. It contains exploratory queries and derived tables/views used to practice advanced business analysis. For the cleaner, presentation-focused version of the e-commerce work, see the dedicated **Ecommerce-SQL-Business-Analysis** repository.

## Analytical areas

| Area | Analysis |
|---|---|
| Customer value | RFM, segmentation, CLV-style metrics |
| Retention | Cohort activity and retention curves |
| Churn | Recency-based risk indicators and churn scoring |
| Revenue | Monthly revenue, growth, moving averages |
| Discounts | Customer discount exposure and CLV comparison |
| Operations | Freight ratios and seller performance |
| Anomalies | Order-level z-score analysis |

## SQL techniques

**MySQL · CTEs · Window Functions · NTILE · LAG · Views · Aggregations · CASE Expressions · Multi-table Joins · Date Functions · Feature Engineering**

The project builds reusable analytical objects such as order-level revenue, customer-level revenue, RFM scores, customer segments, churn tables, CLV-style summaries, monthly revenue tables, and discount analysis tables.

## Example business questions

- Which customers show high-value or at-risk behavior?
- How does customer recency relate to churn risk?
- How concentrated is revenue across customers and sellers?
- How do freight costs affect estimated profitability?
- How does discount exposure relate to customer value?
- How does revenue change month over month?
- Which orders behave like potential outliers?

## Dataset

The SQL workflow is based on the **Olist Brazilian e-commerce dataset** and expects the relevant CSV files to be available locally.

The SQL file currently uses local MySQL `LOAD DATA INFILE` paths, so those paths must be changed for another machine.

## Run locally

1. Install **MySQL 8+**.
2. Place the required Olist CSV files in a MySQL-accessible directory.
3. Update the `LOAD DATA INFILE` paths in `project_ecommerce-intelligence-sql.sql`.
4. Run the SQL script in MySQL Workbench.

## Repository structure

```text
ecommerce-intelligence-sql/
├── project_ecommerce-intelligence-sql.sql
├── Ecommerce_Intelligence_Project_Overview.pdf
├── README.md
└── sql/
```

## Important note

Some queries are exploratory and were written incrementally while developing the analysis. They are intended for **SQL practice and analytical experimentation**, rather than as a production data pipeline.

## Tools

**MySQL · SQL · MySQL Workbench**
