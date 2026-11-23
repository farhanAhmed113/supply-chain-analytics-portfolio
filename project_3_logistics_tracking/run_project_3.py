import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'data', 'logistics.db')
conn = sqlite3.connect(db_path)
cur = conn.cursor()

def print_separator(title):
    print("\n" + "=" * 80)
    print(f" {title.upper()} ")
    print("=" * 80)

print_separator("Project 3: Logistics & Freight Shipment Tracking")

# 1. Carrier Performance vs. Contracted SLA
cur.execute('''
SELECT 
    c.Carrier_Name,
    c.Transport_Mode,
    COUNT(s.Shipment_ID) AS Dispatches,
    ROUND(SUM(s.Freight_Cost_USD), 2) AS Total_Freight_Cost,
    ROUND(AVG(s.Is_On_Time) * 100, 1) AS Actual_OTD_Pct,
    ROUND(c.Target_OTD_SLA * 100, 1) AS Target_SLA_Pct,
    ROUND(AVG(s.Delay_Days), 2) AS Avg_Delay_Days
FROM dim_carriers c
JOIN fact_shipments s ON c.Carrier_ID = s.Carrier_ID
GROUP BY c.Carrier_ID
ORDER BY Total_Freight_Cost DESC;
''')

print(f"{'Carrier Name':<24} | {'Mode':<14} | {'Shipments':<10} | {'Freight Cost':<15} | {'OTD %':<7} | {'SLA %':<7} | {'Avg Delay':<10}")
print("-" * 98)
for r in cur.fetchall():
    print(f"{r[0]:<24} | {r[1]:<14} | {r[2]:<10} | ${r[3]:>12,.2f} | {r[4]:>5.1f}% | {r[5]:>5.1f}% | {r[6]:>5.2f} days")

print_separator("Top Delay Root Causes (Pareto Analysis)")

cur.execute('''
SELECT 
    Delay_Reason,
    COUNT(*) AS Delay_Incidents,
    SUM(Delay_Days) AS Total_Delay_Days,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM fact_shipments WHERE Delay_Reason != 'None'), 1) AS Pct_Share
FROM fact_shipments
WHERE Delay_Reason != 'None'
GROUP BY Delay_Reason
ORDER BY Delay_Incidents DESC;
''')

for r in cur.fetchall():
    print(f"• {r[0]:<30}: {r[1]:>4} incidents | {r[2]:>4} lost days ({r[3]}%)")

conn.close()
print("\n" + "=" * 80)
print("SUCCESS: Logistics analysis completed successfully!")
print("=" * 80 + "\n")
