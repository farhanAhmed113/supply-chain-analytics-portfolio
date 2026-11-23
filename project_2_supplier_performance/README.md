# Supplier Performance & Strategic Procurement Scorecard
**Vendor Reliability, Sourcing Intelligence & Cost Variance Analytics**

[![Tools](https://img.shields.io/badge/Tools-SQL%20|%20Power%20BI%20|%20Excel-blue.svg)]()
[![Domain](https://img.shields.io/badge/Domain-Strategic%20Sourcing%20&%20Procurement-purple.svg)]()
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

---

## 📌 Executive Summary
Strategic procurement requires continuous tracking of supplier reliability, delivery lead times, component quality, and price discipline. Relying on superficial metrics (such as nominal delivery dates) obscures costly issues like partial shipments, quality rejections, and contract price creeping.

This project delivers an **end-to-end Supplier Performance & Procurement Scorecard** that evaluates 15 international suppliers across 2,000+ purchase orders and $32M+ in spend.

---

## 🏗️ Architecture & Data Model

```
 [dim_suppliers]                   [dim_procurement_items]
        \                                     /
         \                                   /
        (1:*)                              (1:*)
      [fact_purchase_orders] <----------------+
```

### Datasets Included
- **`dim_suppliers.csv`**: 15 global vendors across Germany, USA, China, Japan, Sweden, Taiwan, and Mexico with tier classifications, payment terms, and baseline targets.
- **`dim_procurement_items.csv`**: 15 key industrial, automotive, and electronic components with contracted benchmark prices and lead times.
- **`fact_purchase_orders.csv`**: 2,027 purchase order transactions recording ordered vs. delivered quantities, defects, contracted vs. invoiced prices, and delay tracking.

---

## 📊 Key Metrics & Formulas

| Metric | Formula | Purpose |
| :--- | :--- | :--- |
| **On-Time Delivery (OTD %)** | $$\frac{\text{On-Time Orders}}{\text{Total Orders}} \times 100$$ | Measures basic schedule adherence. |
| **In-Full Delivery (IFD %)** | $$\frac{\text{Orders with Delivered Qty } \ge \text{ Ordered Qty}}{\text{Total Orders}} \times 100$$ | Measures order quantity completeness. |
| **OTIF % (Gold Standard)** | $$\frac{\text{Orders On-Time AND In-Full}}{\text{Total Orders}} \times 100$$ | Evaluates true fulfillment capability. |
| **Defect Rate %** | $$\frac{\text{Defective Units}}{\text{Delivered Units}} \times 100$$ | Quality incoming inspection benchmark. |
| **Purchase Price Variance (PPV)** | $$(\text{Actual Price} - \text{Contracted Price}) \times \text{Delivered Qty}$$ | Tracks inflation and off-contract price creeping. |
| **Composite Score Index** | $$(0.40 \times \text{OTIF}) + (0.30 \times \text{Quality}) + (0.20 \times \text{PPV}) + (0.10 \times \text{Lead Time})$$ | Objective 0–100 ranking for vendor QBRs. |

---

## 🔍 Key Findings & Business Impact
1. **The OTIF Reality Check**: While suppliers delivered 88.5% of shipments on or before the promised date, only 82.4% were delivered On-Time *and* In-Full, exposing production line disruption caused by short shipments.
2. **PPV Leakage**: Uncovered **$684,000 in unbudgeted purchase price variance**, highlighting 3 operational suppliers who consistently charged spot rates 5–8% above master service agreements.
3. **Vendor Re-tiering**: Ranked suppliers on an objective 0–100 scale, successfully identifying 4 top-tier strategic partners (e.g. Zurich Precision, Kyoto Ceramics with >95% OTIF) and 2 vendors requiring immediate probation or contract re-negotiation.
