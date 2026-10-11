"""E-commerce Sales & Customer Analytics - Python analysis (pandas + matplotlib).
Run from this folder:  python ecommerce_analysis.py
"""
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

cust = pd.read_csv("customers.csv")
prod = pd.read_csv("products.csv")
orders = pd.read_csv("orders.csv", parse_dates=["order_date"])

for name, df in [("customers", cust), ("products", prod), ("orders", orders)]:
    print(f"{name:10s} rows={len(df):6d} nulls={int(df.isna().sum().sum())} duplicates={int(df.duplicated().sum())}")

df = orders.merge(prod[["product_id", "category"]], on="product_id").merge(cust[["customer_id", "region", "segment", "acquisition_channel"]], on="customer_id")

print("\nKPIs")
print(f"  Orders: {len(df):,}")
print(f"  Revenue (Rs crore): {df.sales.sum()/1e7:,.1f}")
print(f"  Profit (Rs crore): {df.profit.sum()/1e7:,.1f}")
print(f"  Profit margin %: {100*df.profit.sum()/df.sales.sum():.1f}")
print(f"  Return rate %: {100*(df.returned=='Yes').mean():.1f}")
print(f"  Avg order value (Rs): {df.sales.mean():,.0f}")

d = df.groupby("discount_pct").agg(revenue=("sales", "sum"), profit=("profit", "sum"))
d["margin_pct"] = 100 * d.profit / d.revenue
ax = d.margin_pct.plot(kind="bar", figsize=(7, 4), color=["#27ae60" if v > 0 else "#c0392b" for v in d.margin_pct],
                       title="Profit margin % by discount level")
ax.set_xlabel("discount %"); ax.axhline(0, color="black", lw=0.8)
plt.tight_layout(); plt.savefig("charts/margin_by_discount.png", dpi=130); plt.close()

c = df.groupby("category").agg(revenue=("sales", "sum"), profit=("profit", "sum")) / 1e7
ax = c.sort_values("revenue").plot(kind="barh", figsize=(8, 4), title="Revenue and profit by category (Rs crore)")
plt.tight_layout(); plt.savefig("charts/category_revenue_profit.png", dpi=130); plt.close()

m = df.set_index("order_date").resample("MS").sales.sum() / 1e7
ax = m.plot(figsize=(9, 4), marker="o", title="Monthly revenue (Rs crore)"); ax.set_xlabel("")
plt.tight_layout(); plt.savefig("charts/monthly_revenue.png", dpi=130); plt.close()

r = df.groupby("category").apply(lambda x: 100 * (x.returned == "Yes").mean()).sort_values()
ax = r.plot(kind="barh", figsize=(7, 4), title="Return rate % by category", color="#8e44ad")
plt.tight_layout(); plt.savefig("charts/return_rate_by_category.png", dpi=130); plt.close()
print("\nCharts saved to charts/")
