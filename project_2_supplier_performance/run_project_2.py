import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'data', 'procurement.db')
conn = sqlite3.connect(db_path)
cur = conn.cursor()

def print_separator(title):
    print("\n" + "=" * 80)
    print(f" {title.upper()} ")
    print("=" * 80)

print_separator("Project 2: Supplier Scorecard & Procurement Analytics")

# 1. Executive Summary by Tier
cur.execute('''
SELECT 
    s.Vendor_Tier,
    COUNT(DISTINCT s.Supplier_ID) AS Active_Suppliers,
    COUNT(po.PO_Number) AS Total_POs,
    ROUND(SUM(po.Total_PO_Amount), 2) AS Total_Spend_USD,
    ROUND(AVG(po.Is_OTIF) * 100, 1) AS Avg_OTIF_Pct,
    ROUND(SUM(po.Purchase_Price_Variance), 2) AS Net_PPV_USD
FROM dim_suppliers s
JOIN fact_purchase_orders po ON s.Supplier_ID = po.Supplier_ID
GROUP BY s.Vendor_Tier
ORDER BY Total_Spend_USD DESC;
''')

print(f"{'Vendor Tier':<15} | {'Vendors':<8} | {'Total POs':<10} | {'Total Spend':<17} | {'Avg OTIF':<9} | {'Net PPV (Cost Leak)':<18}")
print("-" * 88)
for r in cur.fetchall():
    print(f"{r[0]:<15} | {r[1]:<8} | {r[2]:<10} | ${r[3]:>14,.2f} | {r[4]:>7.1f}% | ${r[5]:>16,.2f}")

print_separator("Top 5 Performing Suppliers (By Spend & OTIF)")

cur.execute('''
SELECT 
    s.Supplier_Name,
    s.Country,
    s.Vendor_Tier,
    COUNT(po.PO_Number) AS Orders,
    ROUND(SUM(po.Total_PO_Amount), 2) AS Total_Spend,
    ROUND(AVG(po.Is_OTIF) * 100, 1) AS OTIF_Pct,
    ROUND((SUM(po.Defect_Qty) * 100.0) / NULLIF(SUM(po.Delivered_Qty), 0), 2) AS Defect_Rate_Pct
FROM dim_suppliers s
JOIN fact_purchase_orders po ON s.Supplier_ID = po.Supplier_ID
GROUP BY s.Supplier_ID
ORDER BY Total_Spend DESC
LIMIT 5;
''')

print(f"{'Supplier Name':<28} | {'Country':<12} | {'Orders':<6} | {'Spend':<14} | {'OTIF %':<8} | {'Defect %':<8}")
print("-" * 88)
for r in cur.fetchall():
    print(f"{r[0]:<28} | {r[1]:<12} | {r[3]:<6} | ${r[4]:>11,.2f} | {r[5]:>6.1f}% | {r[6]:>6.2f}%")

conn.close()
print("\n" + "=" * 80)
print("SUCCESS: Supplier Performance analysis completed successfully!")
print("=" * 80 + "\n")
