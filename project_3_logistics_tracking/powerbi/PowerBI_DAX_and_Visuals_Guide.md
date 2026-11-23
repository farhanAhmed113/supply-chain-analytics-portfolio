# Power BI Implementation Guide: Logistics & Shipment Tracking Analysis

This guide provides the complete blueprint to build an interactive Logistics & Carrier Performance Dashboard in Power BI.

---

## 1. Data Model Architecture (Star Schema)

Import the 3 CSV files into Power BI Desktop:
1. `dim_carriers.csv`
2. `dim_routes.csv`
3. `fact_shipments.csv`

```
   [dim_carriers]                   [dim_routes]
         |                                |
    (1)  |                           (1)  |
         v                                v
    [fact_shipments] <--------------------+
```

### Table Relationships (Model View)
- **`dim_carriers` [1] to `fact_shipments` [*]**
  - Key: `Carrier_ID` (1:*)
- **`dim_routes` [1] to `fact_shipments` [*]**
  - Key: `Route_ID` (1:*)

---

## 2. Calculated Columns (Data View)

In `fact_shipments`:

```dax
Lane_Name = 
RELATED(dim_routes[Origin]) & " ➔ " & RELATED(dim_routes[Destination])
```

```dax
Ton_Miles = 
(fact_shipments[Weight_Kg] / 1000.0) * RELATED(dim_routes[Distance_Miles])
```

```dax
Delivery_Status_Clean = 
IF(fact_shipments[Is_On_Time] = 1, "On-Time", "Delayed")
```

---

## 3. Core DAX Measures (Copy & Paste)

### 1. Total Freight Cost
```dax
Total Freight Cost = 
SUM(fact_shipments[Freight_Cost_USD])
```

### 2. Total Dispatched Shipments
```dax
Total Shipments = 
COUNTROWS(fact_shipments)
```

### 3. On-Time Delivery Rate (%) - Key KPI
```dax
On-Time Delivery % = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_shipments), fact_shipments[Is_On_Time] = 1),
    COUNTROWS(fact_shipments),
    0
)
```

### 4. Delayed Shipments Count
```dax
Delayed Shipments Count = 
CALCULATE(
    COUNTROWS(fact_shipments), 
    fact_shipments[Is_On_Time] = 0
)
```

### 5. Average Delivery Delay (Days)
```dax
Avg Delay Days = 
AVERAGE(fact_shipments[Delay_Days])
```

### 6. Average Cost per Shipment
```dax
Avg Cost per Shipment = 
DIVIDE([Total Freight Cost], [Total Shipments], 0)
```

### 7. Cost per Ton-Mile
```dax
Cost per Ton-Mile = 
DIVIDE(
    [Total Freight Cost], 
    SUM(fact_shipments[Ton_Miles]), 
    0
)
```

### 8. Target SLA Benchmark (Carrier Average)
```dax
Target SLA Benchmark = 
AVERAGE(dim_carriers[Target_OTD_SLA])
```

---

## 4. Visual Dashboard Canvas Layout

### Canvas Structure (16:9)
```
+-----------------------------------------------------------------------------------------------+
| HEADER: Logistics & Transportation Performance Tracking Dashboard                            |
| Slicers: [Transport Mode]  |  [Carrier Name]  |  [Priority (Standard/Expedited)]  |  [Date]   |
+-----------------------------------------------------------------------------------------------+
| KPI 1: Total Freight | KPI 2: Total Shipments | KPI 3: OTD Rate %  | KPI 4: Avg Delay | KPI 5: Cost/Ton-Mile |
| $10.8M               | 4,017                  | 87.7% (Goal: 92%)  | 0.25 Days        | $1.18                |
+-----------------------------------------------------------------------------------------------+
| [CLUSTERED BAR CHART]                             | [DONUT / PARETO BAR CHART]                |
| Carrier On-Time Delivery vs. SLA                  | Delay Incidents by Root Cause             |
| - DHL Expedited: 92.4%                            | - Weather / Storm: 28%                    |
| - UPS Supply Chain: 89.8%                         | - Port / Customs Congestion: 24%          |
| - FedEx Freight: 88.5%                            | - Driver & Labor Shortage: 20%            |
| - Schneider FTL: 87.0%                            | - Route Bottlenecks: 16%                  |
| - Swift FTL: 84.7%                                | - Mechanical / Docs: 12%                  |
+---------------------------------------------------+-------------------------------------------+
| [INTERACTIVE SHIPPING LANE TABLE / HEATMAP]                                                   |
| Origin Hub | Destination DC | Distance | Dispatches | OTD % | Avg Delay | Total Freight Cost  |
+-----------------------------------------------------------------------------------------------+
```

### Recommended Visual Palette
- **On-Time Delivery**: `#2E7D32` (Green)
- **Delayed Delivery**: `#D32F2F` (Crimson Red)
- **SLA Target Line**: `#000000` (Dashed Black Line)
