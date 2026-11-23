# Power BI Implementation Guide: Supplier Performance & Procurement Scorecard

This guide provides the complete blueprint to build an executive Procurement & Supplier Scorecard dashboard in Power BI.

---

## 1. Data Model Architecture (Star Schema)

Import the 3 CSV files into Power BI Desktop:
1. `dim_suppliers.csv`
2. `dim_procurement_items.csv`
3. `fact_purchase_orders.csv`

```
 [dim_suppliers]                   [dim_procurement_items]
        |                                     |
   (1)  |                                (1)  |
        v                                     v
   [fact_purchase_orders] <--------------------+
```

### Table Relationships (Model View)
- **`dim_suppliers` [1] to `fact_purchase_orders` [*]**
  - Key: `Supplier_ID` (1:*)
- **`dim_procurement_items` [1] to `fact_purchase_orders` [*]**
  - Key: `Item_ID` (1:*)

---

## 2. Calculated Columns (fact_purchase_orders)

```dax
Delivery_Status = 
IF(fact_purchase_orders[Is_On_Time] = 1, "On-Time", "Delayed")
```

```dax
OTIF_Status = 
IF(fact_purchase_orders[Is_OTIF] = 1, "OTIF Met", "OTIF Breached")
```

---

## 3. Core DAX Measures (Copy & Paste)

### 1. Total Procurement Spend
```dax
Total Spend = 
SUM(fact_purchase_orders[Total_PO_Amount])
```

### 2. Total Purchase Orders Count
```dax
Total PO Count = 
COUNTROWS(fact_purchase_orders)
```

### 3. On-Time Delivery Rate (%)
```dax
On-Time Delivery % = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_purchase_orders), fact_purchase_orders[Is_On_Time] = 1),
    COUNTROWS(fact_purchase_orders),
    0
)
```

### 4. In-Full Delivery Rate (%)
```dax
In-Full Delivery % = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_purchase_orders), fact_purchase_orders[Is_In_Full] = 1),
    COUNTROWS(fact_purchase_orders),
    0
)
```

### 5. On-Time In-Full (OTIF) Rate (%) - The Key KPI
```dax
OTIF Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_purchase_orders), fact_purchase_orders[Is_OTIF] = 1),
    COUNTROWS(fact_purchase_orders),
    0
)
```

### 6. Defect / Rejection Rate (%)
```dax
Defect Rate % = 
DIVIDE(
    SUM(fact_purchase_orders[Defect_Qty]),
    SUM(fact_purchase_orders[Delivered_Qty]),
    0
)
```

### 7. Quality Acceptance Rate (%)
```dax
Quality Acceptance Rate % = 
1 - [Defect Rate %]
```

### 8. Net Purchase Price Variance (PPV)
```dax
Net PPV = 
SUM(fact_purchase_orders[Purchase_Price_Variance])
```

### 9. Supplier Composite Score (0 to 100)
```dax
Supplier Composite Score = 
([OTIF Rate %] * 40) + 
([Quality Acceptance Rate %] * 30) + 
(MAX(0, 1 - ([Net PPV] / [Total Spend])) * 20) + 
(10)
```

---

## 4. Visual Dashboard Layout & Canvas Design

### Canvas Structure (16:9)
```
+-----------------------------------------------------------------------------------------------+
| HEADER: Strategic Procurement & Supplier Performance Scorecard                                 |
| Slicers: [Vendor Tier (Strategic/Preferred/Operational)]  |  [Country]  |  [Category]         |
+-----------------------------------------------------------------------------------------------+
| KPI 1: Total Spend  | KPI 2: Total POs  | KPI 3: OTIF %       | KPI 4: Quality Rate | KPI 5: PPV Leakage |
| $32.4M              | 2,027             | 82.4% (Goal: 90%)   | 98.4%               | +$684K             |
+-----------------------------------------------------------------------------------------------+
| [SCATTER PLOT]                                    | [DONUT / CLUSTERED COLUMN CHART]          |
| Vendor Quality vs. On-Time Delivery               | Spend by Country & Tier                   |
| X-Axis: OTIF %                                    | - Germany: $11.5M                         |
| Y-Axis: Quality Acceptance %                      | - Sweden: $6.9M                           |
| Size: Total Spend ($)                             | - USA: $5.1M                              |
+---------------------------------------------------+-------------------------------------------+
| [INTERACTIVE VENDOR SCORECARD MATRIX]                                                         |
| Supplier Name | Category | Tier | Total POs | Spend | OTIF % | Defect % | Net PPV | Status   |
+-----------------------------------------------------------------------------------------------+
```

### Conditional Formatting Color Rules
- **OTIF %**: $\ge 90\%$ Green (`#2E7D32`), $80-89\%$ Yellow (`#F57C00`), $<80\%$ Red (`#D32F2F`)
- **Defect %**: $\le 1.0\%$ Green, $1.0-2.5\%$ Yellow, $>2.5\%$ Red
