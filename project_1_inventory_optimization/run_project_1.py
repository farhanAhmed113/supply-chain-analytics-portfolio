import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'data', 'inventory.db')
conn = sqlite3.connect(db_path)
cur = conn.cursor()

def print_separator(title):
    print("\n" + "=" * 80)
    print(f" {title.upper()} ")
    print("=" * 80)

print_separator("Project 1: Inventory Health & Valuation Report")

# 1. Valuation by Category
cur.execute('''
SELECT 
    p.Category,
    COUNT(DISTINCT p.Product_ID) AS Total_SKUs,
    SUM(i.Stock_On_Hand) AS Total_Units,
    ROUND(SUM(i.Stock_On_Hand * p.Unit_Cost), 2) AS Inventory_Value_USD,
    ROUND(SUM(i.Annual_Holding_Cost), 2) AS Annual_Holding_Cost_USD
FROM fact_inventory i
JOIN dim_products p ON i.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Inventory_Value_USD DESC;
''')

rows = cur.fetchall()
print(f"{'Category':<22} | {'SKUs':<5} | {'Units':<7} | {'Inventory Value':<17} | {'Annual Holding Cost':<20}")
print("-" * 80)
for r in rows:
    print(f"{r[0]:<22} | {r[1]:<5} | {r[2]:<7} | ${r[3]:>14,.2f} | ${r[4]:>17,.2f}")

print_separator("Stock Health Status Breakdown")

cur.execute('''
WITH StockHealth AS (
    SELECT 
        i.Warehouse_ID,
        p.Product_ID,
        p.Product_Name,
        i.Available_Stock,
        i.Safety_Stock,
        i.Reorder_Point,
        CASE 
            WHEN i.Available_Stock = 0 THEN '1. Stockout'
            WHEN i.Available_Stock < i.Safety_Stock THEN '2. Critical (< Safety Stock)'
            WHEN i.Available_Stock <= i.Reorder_Point THEN '3. Reorder Needed'
            WHEN i.Available_Stock > (i.Reorder_Point * 2.5) THEN '5. Overstocked'
            ELSE '4. Healthy'
        END AS Stock_Status
    FROM fact_inventory i
    JOIN dim_products p ON i.Product_ID = p.Product_ID
)
SELECT 
    Stock_Status,
    COUNT(*) AS SKU_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_inventory), 1) AS Percent_Share
FROM StockHealth
GROUP BY Stock_Status
ORDER BY Stock_Status;
''')

for r in cur.fetchall():
    print(f"• {r[0]:<30}: {r[1]:>3} SKU locations ({r[2]}%)")

print_separator("Top 5 Critical Replenishment Recommendations (Order Now)")

cur.execute('''
SELECT 
    w.Warehouse_Name,
    p.Product_Name,
    p.Category,
    i.Available_Stock,
    i.Safety_Stock,
    i.Reorder_Point,
    CASE 
        WHEN ((i.Reorder_Point * 2) - i.Available_Stock) < i.MOQ THEN i.MOQ
        ELSE ((i.Reorder_Point * 2) - i.Available_Stock)
    END AS Order_Qty,
    ROUND(
        (CASE 
            WHEN ((i.Reorder_Point * 2) - i.Available_Stock) < i.MOQ THEN i.MOQ
            ELSE ((i.Reorder_Point * 2) - i.Available_Stock)
        END) * p.Unit_Cost, 2
    ) AS Est_Cost_USD
FROM fact_inventory i
JOIN dim_products p ON i.Product_ID = p.Product_ID
JOIN dim_warehouses w ON i.Warehouse_ID = w.Warehouse_ID
WHERE i.Available_Stock <= i.Safety_Stock
ORDER BY (i.Safety_Stock - i.Available_Stock) DESC
LIMIT 5;
''')

print(f"{'Warehouse':<24} | {'Product Name':<28} | {'Stock':<6} | {'Order Qty':<9} | {'Est. Cost':<12}")
print("-" * 88)
for r in cur.fetchall():
    print(f"{r[0]:<24} | {r[1]:<28} | {r[3]:<6} | {r[6]:<9} | ${r[7]:>9,.2f}")

conn.close()
print("\n" + "=" * 80)
print("SUCCESS: Report generated from SQLite database without any external setup!")
print("=" * 80 + "\n")
