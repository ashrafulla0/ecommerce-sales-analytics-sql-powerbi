# E-commerce Sales & Customer Analytics

**Business problem:** Which categories, discounts, customers and channels drive profit — and where is the business losing money?

## Dataset
Synthetic dataset generated programmatically with Python (fixed random seed). It contains no real customer or company data. Each order row is one product line (Jan 2024 – Dec 2025).

| Table | Rows |
|---|---|
| orders | 25,000 |
| customers | 3,000 |
| products | 100 |

**Total: 28,100 records across 3 tables.**

## Tools
MySQL 8 (joins, CTEs, window functions) · Python (pandas, matplotlib) · Power BI (DAX)

## Repository contents
- `*.csv` — the 3 tables
- `schema_and_load.sql` — creates the MySQL tables and loads the CSVs
- `ecommerce_15_questions.sql` — 15 business questions answered in SQL
- `ecommerce_analysis.py` — data-quality checks, KPIs and charts
- `charts/` — charts produced by the Python script
- `dashboard.png` / `Ecommerce_Dashboard.pbix` — Power BI dashboard (one page)

## Headline numbers
Revenue **₹47.1 crore** · Profit **₹4.9 crore** · Margin **10.3%** · 25,000 orders · Avg order value ₹18,834 · Return rate 7.6%

## Key insights
1. **Discounts destroy profit:** margin falls from 19.6% (no discount) to 4.8% at 15%, then turns negative — -0.6% at 20%, -15.9% at 30% and -33.4% at 40%. The 5,865 orders discounted 20%+ (23.5% of orders) lost ₹0.88 crore combined.
2. **Electronics is big but thin:** 67.4% of revenue at only a 2.0% margin. Beauty (44.1%) and Fashion (39.5%) have the best margins; Home & Kitchen earns the most profit (₹1.69 crore at 22.5%).
3. **Fashion returns:** 15.5% return rate, about double the 7.6% average. Books is lowest at 2.9%.
4. **Seasonality:** October–December brings 37.7% of revenue, and October 2024 revenue jumped 52% over September.
5. **Channels:** Referral has the fewest customers (291) but the highest revenue per customer (₹2.39 lakh), 1.8x Paid Ads (₹1.34 lakh). Organic Search brings the most total revenue (₹16.9 crore).
6. **Concentration:** the top 10% of customers (274) generate 43.7% of revenue.
7. **Regions:** South leads with ₹15.3 crore revenue; East is smallest but has the highest average order value (₹19,541).

## Recommendations
- Cap discounts at 15%, especially on Electronics, where the margin is only 2%.
- Reduce Fashion returns (size guides, better product photos and descriptions).
- Invest in the referral programme and protect the top-10% customer group with loyalty offers.
- Plan inventory and marketing around the Q4 peak.

## How to run
1. Create the tables: run `schema_and_load.sql` (change the CSV folder path first).
2. Run `ecommerce_15_questions.sql` in MySQL Workbench.
3. `pip install pandas matplotlib` then `python ecommerce_analysis.py`.
4. Open the Power BI file and refresh from the CSVs.

## Power BI dashboard
![Dashboard](dashboard.png)
