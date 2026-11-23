# Inventory Management & Stock Optimization Dashboard
**Supply Chain Analytics & Replenishment Intelligence**

[![Tools](https://img.shields.io/badge/Tools-SQL%20|%20Power%20BI%20|%20Excel-blue.svg)]()
[![Domain](https://img.shields.io/badge/Domain-Supply%20Chain%20Operations-green.svg)]()
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

---

## 📌 Executive Summary
In complex multi-echelon supply chains, balancing inventory availability against holding costs is critical. Holding too much inventory ties up working capital and inflates carrying costs; holding too little leads to lost revenue, expedited freight fees, and customer churn.

This project delivers an **end-to-end inventory optimization solution** that analyzes historical demand variability, computes dynamic statistical safety stocks and reorder points, segments inventory via ABC Pareto analysis, and surfaces actionable replenishment alerts through an interactive Power BI dashboard.

---

## 🏗️ Architecture & Data Model

The project is structured around a **Star Schema** data model designed for high-performance querying and cross-filtering:

```
[dim_warehouses]               [dim_products]
       \                             /
        \                           /
      (1:*)                       (1:*)
     [fact_inventory] <-----(*)---- [fact_sales_orders]
```

### Datasets Included
- **`dim_products.csv`**: 48 SKUs across 4 categories (Industrial, Automotive, Electronics, Fasteners), unit costs, wholesale prices, and supplier lead times.
- **`dim_warehouses.csv`**: 3 strategic regional fulfillment centers (Chicago Midwest Hub, Newark East Depot, Reno West Center).
- **`fact_sales_orders.csv`**: 8,400+ order lines capturing daily sales velocity and seasonal demand swings across 12 months.
- **`fact_inventory.csv`**: Granular inventory levels, reserved stock, safety buffers, reorder thresholds, and annual holding costs.

---

## 📊 Key Metrics & Formulas

| Metric | Formula | Purpose |
| :--- | :--- | :--- |
| **Safety Stock (SS)** | $$Z \times \sigma_d \times \sqrt{L}$$ | Buffer against demand spikes during lead time ($Z=1.65$ for 95% service level). |
| **Reorder Point (ROP)** | $$(ADS \times L) + SS$$ | Triggers replenishment orders before stock dips into safety stock. |
| **Inventory Turnover Ratio (ITR)** | $$\frac{\text{COGS}}{\text{Average Inventory Value}}$$ | Evaluates how many times inventory is sold and replaced per year. |
| **Days Sales of Inventory (DSI)** | $$\frac{365}{\text{ITR}}$$ | Average days taken to convert inventory into finished sales. |
| **Stockout Rate (%)** | $$\frac{\text{Out of Stock SKUs}}{\text{Total Active SKUs}} \times 100$$ | Measures order fulfillment resilience. |

---

## 🔍 Key Findings & Business Impact
1. **Capital Optimization**: Identified **$65,400** tied up in overstocked items (>2.5x ROP), creating immediate opportunities to free up working capital and trim holding costs by 18%.
2. **Stockout Prevention**: Detected **8 out-of-stock items** and **7 critical SKUs** below safety stock; generated automated purchase orders to restore target 95% service level.
3. **Pareto 80/20 Alignment**: Revealed that the top **10 SKUs (21% of catalog) drive 66.5% of total revenue**, allowing purchasing teams to concentrate negotiated vendor terms on core Class A drivers.

---

## 🚀 How to Run the Project
1. **Database / SQL**: Open `sql/inventory_analytics.sql` in any SQL IDE (PostgreSQL, MySQL, DBeaver, or SQLite) and run against the CSV files or SQLite database in `data/inventory.db`.
2. **Power BI**:
   - Open Power BI Desktop.
   - Load CSVs from `data/`.
   - Verify relationships in Model View.
   - Follow `powerbi/PowerBI_DAX_and_Visuals_Guide.md` for DAX measures and canvas layout.
