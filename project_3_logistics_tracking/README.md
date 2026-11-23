# Logistics & Freight Shipment Tracking Analysis
**Transportation Network Intelligence, Carrier SLA Compliance & Freight Cost Optimization**

[![Tools](https://img.shields.io/badge/Tools-SQL%20|%20Power%20BI%20|%20Excel-blue.svg)]()
[![Domain](https://img.shields.io/badge/Domain-Logistics%20&%20Transportation-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

---

## 📌 Executive Summary
In downstream supply chain operations, carrier delays and unchecked transportation premiums can erode operating margins rapidly. Transportation managers need real-time visibility into carrier performance against contracted Service Level Agreements (SLAs), lane-level delay patterns, and freight cost efficiency.

This project delivers an **end-to-end Logistics & Shipment Tracking solution** analyzing 4,000+ freight movements across 12 transit corridors, 6 major logistics carriers, and $10.8M in freight expenditure.

---

## 🏗️ Architecture & Data Model

```
   [dim_carriers]                   [dim_routes]
         \                                /
          \                              /
         (1:*)                         (1:*)
       [fact_shipments] <----------------+
```

### Datasets Included
- **`dim_carriers.csv`**: 6 multi-modal carriers (FedEx, DHL, Maersk, UPS, Schneider, Swift) across Road FTL, Road LTL, Air Expedited, and Intermodal modes with contracted baseline OTD SLAs.
- **`dim_routes.csv`**: 12 high-volume US freight corridors with distance mileage and standard transit day benchmarks.
- **`fact_shipments.csv`**: 4,017 dispatches capturing scheduled vs. actual delivery dates, delay days, root cause categories, shipment weight, priority levels, and freight costs.

---

## 📊 Key Metrics & Formulas

| Metric | Formula | Purpose |
| :--- | :--- | :--- |
| **On-Time Delivery (OTD %)** | $$\frac{\text{On-Time Dispatches}}{\text{Total Dispatches}} \times 100$$ | Evaluates carrier SLA compliance. |
| **Average Delay Days** | $$\frac{\text{Total Delay Days}}{\text{Count of Delayed Shipments}}$$ | Quantifies delivery disruption severity. |
| **Cost per Ton-Mile** | $$\frac{\text{Total Freight Cost}}{\sum (\text{Tons} \times \text{Distance Miles})}$$ | Normalized freight cost efficiency benchmark. |
| **Expedited Cost Premium** | $$\text{Avg Cost}_{\text{Expedited}} - \text{Avg Cost}_{\text{Standard}}$$ | Measures financial penalty of emergency shipments. |

---

## 🔍 Key Findings & Business Impact
1. **SLA Deficits on Long-Haul Corridors**: Carriers achieved an overall 87.7% OTD against an average contracted SLA target of 92%, with the largest deficits concentrated on intermodal lanes exceeding 1,000 miles.
2. **Delay Root-Cause Breakdown**: 52% of all delivery delays were attributable to external constraints (severe weather and port container congestion), demonstrating that freight routing adjustments—rather than carrier punitive actions—were necessary.
3. **Expedited Premium Waste**: Identified **$1.4M in avoidable expedited shipping surcharges** caused by delayed upstream order picking in regional warehouses, creating a compelling business case for cross-functional warehouse-transportation scheduling synchronization.
