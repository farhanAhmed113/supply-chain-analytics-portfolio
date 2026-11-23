# Power BI Implementation Guide: Inventory Management & Stock Optimization Dashboard

This guide provides the complete blueprint to build an interactive, executive-ready Power BI dashboard in **less than 30 minutes**.

---

## 1. Data Model Architecture (Star Schema)

When importing the CSV files into Power BI Desktop (`Home` -> `Get Data` -> `Text/CSV`):

```
       [dim_warehouses]               [dim_products]
              |                              |
         (1)  |                         (1)  |
              v                              v
       [fact_inventory] <-----(*)---- [fact_sales_orders]
```

### Table Relationships (Model View)
1. **`dim_products` [1] to `fact_inventory` [*]**
   - Key: `Product_ID`
   - Cardinality: One to Many (1:*)
   - Cross filter direction: Single
2. **`dim_warehouses` [1] to `fact_inventory` [*]**
   - Key: `Warehouse_ID`
   - Cardinality: One to Many (1:*)
   - Cross filter direction: Single
3. **`dim_products` [1] to `fact_sales_orders` [*]**
   - Key: `Product_ID`
   - Cardinality: One to Many (1:*)
   - Cross filter direction: Single
4. **`dim_warehouses` [1] to `fact_sales_orders` [*]**
   - Key: `Warehouse_ID`
   - Cardinality: One to Many (1:*)
   - Cross filter direction: Single

---

## 2. Calculated Columns (Data View)

Select `fact_inventory` table and add this calculated column:

```dax
Stock_Status = 
SWITCH(
    TRUE(),
    fact_inventory[Available_Stock] = 0, "1. Stockout",
    fact_inventory[Available_Stock] < fact_inventory[Safety_Stock], "2. Critical (< Safety Stock)",
    fact_inventory[Available_Stock] <= fact_inventory[Reorder_Point], "3. Reorder Needed",
    fact_inventory[Available_Stock] > (fact_inventory[Reorder_Point] * 2.5), "5. Overstocked",
    "4. Healthy"
)
```

Add Inventory Value column in `fact_inventory`:
```dax
Inventory_Valuation = 
fact_inventory[Stock_On_Hand] * RELATED(dim_products[Unit_Cost])
```

---

## 3. Core DAX Measures (Copy & Paste)

Create a dedicated measure table or add these to `fact_inventory`:

### 1. Total Inventory Valuation
```dax
Total Inventory Value = 
SUMX(fact_inventory, fact_inventory[Stock_On_Hand] * RELATED(dim_products[Unit_Cost]))
```

### 2. Total Annual Holding Cost
```dax
Total Holding Cost = 
SUM(fact_inventory[Annual_Holding_Cost])
```

### 3. Total Available Stock Units
```dax
Total Available Units = 
SUM(fact_inventory[Available_Stock])
```

### 4. Stockout Rate (%)
```dax
Stockout Rate % = 
VAR TotalSKUs = COUNTROWS(fact_inventory)
VAR OutOfStockSKUs = CALCULATE(COUNTROWS(fact_inventory), fact_inventory[Available_Stock] = 0)
RETURN
DIVIDE(OutOfStockSKUs, TotalSKUs, 0)
```

### 5. SKUs Requiring Reorder
```dax
SKUs Needing Reorder = 
CALCULATE(
    COUNTROWS(fact_inventory), 
    fact_inventory[Available_Stock] <= fact_inventory[Reorder_Point]
)
```

### 6. Overstocked Capital Tied Up
```dax
Overstocked Capital = 
CALCULATE(
    [Total Inventory Value], 
    fact_inventory[Stock_Status] = "5. Overstocked"
)
```

### 7. Total Sales Revenue
```dax
Total Sales Revenue = 
SUM(fact_sales_orders[Sales_Amount])
```

### 8. Total Cost of Goods Sold (COGS)
```dax
Total COGS = 
SUMX(fact_sales_orders, fact_sales_orders[Quantity_Sold] * RELATED(dim_products[Unit_Cost]))
```

### 9. Inventory Turnover Ratio (ITR)
```dax
Inventory Turnover Ratio = 
DIVIDE([Total COGS], [Total Inventory Value], 0)
```

### 10. Days Sales of Inventory (DSI)
```dax
Days Sales of Inventory = 
DIVIDE(365, [Inventory Turnover Ratio], 0)
```

---

## 4. Dashboard Canvas Layout & Visuals

### Layout Structure (16:9 Canvas)

```
+-----------------------------------------------------------------------------------------------+
| HEADER: Supply Chain Inventory Optimization & Replenishment Dashboard                         |
| Filters: [Category Slicer]  |  [Warehouse Slicer]  |  [Stock Status Slicer]                   |
+-----------------------------------------------------------------------------------------------+
| KPI 1: Total Value  | KPI 2: Holding Cost | KPI 3: Stockout Rate | KPI 4: Need Reorder | KPI 5: ITR  |
| $361.9K             | $72.3K              | 5.6% (8 SKUs)        | 45 SKUs             | 4.8x        |
+-----------------------------------------------------------------------------------------------+
| [DONUT CHART]                     | [STACKED BAR CHART]                                       |
| Stock Health Distribution         | Inventory Valuation by Category                           |
| - Healthy: 45% (Green)            | - Industrial: $167.9K                                     |
| - Reorder Needed: 26% (Orange)    | - Automotive: $101.8K                                     |
| - Overstocked: 18% (Blue)         | - Electronics: $70.6K                                     |
| - Critical/Stockout: 11% (Red)    | - Fasteners: $21.5K                                       |
+-----------------------------------+-----------------------------------------------------------+
| [INTERACTIVE REPLENISHMENT ACTION TABLE]                                                      |
| Product Name | Category | Available Stock | Safety Stock | ROP | Recommended Order | Est. Cost|
+-----------------------------------------------------------------------------------------------+
```

### Suggested Visual Palette
- **Stockout / Critical**: `#D32F2F` (Crimson Red)
- **Reorder Needed**: `#F57C00` (Amber / Orange)
- **Healthy**: `#2E7D32` (Forest Green)
- **Overstocked**: `#1976D2` (Royal Blue)

---

## 5. Ready-Made Publishing & Portfolio Tips
1. Once built in Power BI Desktop, click **File -> Export to PDF** to keep high-res screenshots for your portfolio or LinkedIn.
2. Publish to Power BI Service (free account) and click **File -> Publish to Web (Public)** to get an interactive embed link you can link directly from your resume!
