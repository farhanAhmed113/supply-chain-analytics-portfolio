-- =====================================================================
-- PROJECT 2: SUPPLIER PERFORMANCE & STRATEGIC PROCUREMENT SCORECARD
-- Dialect: Standard ANSI SQL (PostgreSQL, MySQL, SQL Server, SQLite)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABLE CREATION (DDL)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dim_suppliers (
    Supplier_ID VARCHAR(20) PRIMARY KEY,
    Supplier_Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Payment_Terms VARCHAR(20) NOT NULL,
    Vendor_Tier VARCHAR(20) NOT NULL,
    Target_OTD DECIMAL(4,2) NOT NULL,
    Defect_Baseline DECIMAL(4,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_procurement_items (
    Item_ID VARCHAR(20) PRIMARY KEY,
    Item_Name VARCHAR(100) NOT NULL,
    Primary_Supplier_ID VARCHAR(20) NOT NULL,
    Contracted_Unit_Price DECIMAL(10,2) NOT NULL,
    Standard_Lead_Time_Days INT NOT NULL,
    FOREIGN KEY (Primary_Supplier_ID) REFERENCES dim_suppliers(Supplier_ID)
);

CREATE TABLE IF NOT EXISTS fact_purchase_orders (
    PO_Number VARCHAR(50) PRIMARY KEY,
    PO_Date DATE NOT NULL,
    Supplier_ID VARCHAR(20) NOT NULL,
    Item_ID VARCHAR(20) NOT NULL,
    Ordered_Qty INT NOT NULL,
    Delivered_Qty INT NOT NULL,
    Accepted_Qty INT NOT NULL,
    Defect_Qty INT NOT NULL,
    Contracted_Unit_Price DECIMAL(10,2) NOT NULL,
    Actual_Unit_Price DECIMAL(10,2) NOT NULL,
    Total_PO_Amount DECIMAL(12,2) NOT NULL,
    Purchase_Price_Variance DECIMAL(12,2) NOT NULL,
    Promised_Delivery_Date DATE NOT NULL,
    Actual_Delivery_Date DATE NOT NULL,
    Delivery_Delay_Days INT NOT NULL,
    Is_On_Time INT NOT NULL,
    Is_In_Full INT NOT NULL,
    Is_OTIF INT NOT NULL,
    Payment_Status VARCHAR(30) NOT NULL,
    FOREIGN KEY (Supplier_ID) REFERENCES dim_suppliers(Supplier_ID),
    FOREIGN KEY (Item_ID) REFERENCES dim_procurement_items(Item_ID)
);

-- ---------------------------------------------------------------------
-- 2. PROCUREMENT KPIS & EXECUTIVE SCORECARD QUERIES
-- ---------------------------------------------------------------------

-- QUERY 1: EXECUTIVE PROCUREMENT SPEND & VOLUME SUMMARY
-- Business Purpose: Total spend by Supplier Tier and Country
SELECT 
    s.Vendor_Tier,
    COUNT(DISTINCT s.Supplier_ID) AS Active_Suppliers,
    COUNT(po.PO_Number) AS Total_Purchase_Orders,
    ROUND(SUM(po.Total_PO_Amount), 2) AS Total_Procurement_Spend_USD,
    ROUND(AVG(po.Total_PO_Amount), 2) AS Avg_PO_Value_USD,
    ROUND(SUM(po.Purchase_Price_Variance), 2) AS Net_Purchase_Price_Variance_USD
FROM dim_suppliers s
JOIN fact_purchase_orders po ON s.Supplier_ID = po.Supplier_ID
GROUP BY s.Vendor_Tier
ORDER BY Total_Procurement_Spend_USD DESC;


-- QUERY 2: COMPREHENSIVE SUPPLIER SCORECARD (OTIF, QUALITY, SPEND)
-- Business Purpose: Evaluate supplier performance against industry standard KPIs:
-- 1. OTD (On-Time Delivery %)
-- 2. IFD (In-Full Delivery %)
-- 3. OTIF (On-Time In-Full %) -> The ultimate supply chain fulfillment metric
-- 4. Defect Rate % (Quality)
-- 5. PPV (Purchase Price Variance)
SELECT 
    s.Supplier_ID,
    s.Supplier_Name,
    s.Country,
    s.Category,
    COUNT(po.PO_Number) AS Total_Orders,
    ROUND(SUM(po.Total_PO_Amount), 2) AS Total_Spend_USD,
    -- Fulfillment Metrics
    ROUND(AVG(po.Is_On_Time) * 100, 1) AS On_Time_Delivery_Pct,
    ROUND(AVG(po.Is_In_Full) * 100, 1) AS In_Full_Delivery_Pct,
    ROUND(AVG(po.Is_OTIF) * 100, 1) AS OTIF_Fulfillment_Pct,
    ROUND(AVG(po.Delivery_Delay_Days), 1) AS Avg_Delivery_Delay_Days,
    -- Quality Metrics
    SUM(po.Delivered_Qty) AS Total_Delivered_Units,
    SUM(po.Defect_Qty) AS Total_Defective_Units,
    ROUND((SUM(po.Defect_Qty) * 100.0) / NULLIF(SUM(po.Delivered_Qty), 0), 2) AS Defect_Rate_Pct,
    -- Financial Compliance
    ROUND(SUM(po.Purchase_Price_Variance), 2) AS Total_Price_Variance_USD,
    ROUND((SUM(po.Purchase_Price_Variance) * 100.0) / NULLIF(SUM(po.Total_PO_Amount), 0), 2) AS Price_Variance_Pct
FROM dim_suppliers s
JOIN fact_purchase_orders po ON s.Supplier_ID = po.Supplier_ID
GROUP BY s.Supplier_ID, s.Supplier_Name, s.Country, s.Category
ORDER BY Total_Spend_USD DESC;


-- QUERY 3: COMPOSITE SUPPLIER PERFORMANCE RATING INDEX (WEIGHTED SCORE)
-- Business Purpose: Calculate an objective 0-100 score for vendor tiering:
-- - 40% Weight: OTIF Fulfillment
-- - 30% Weight: Quality Acceptance Rate (100% - Defect %)
-- - 20% Weight: Price Discipline (100% - PPV Penalty)
-- - 10% Weight: Lead Time Adherence
WITH SupplierMetrics AS (
    SELECT 
        s.Supplier_ID,
        s.Supplier_Name,
        s.Vendor_Tier,
        ROUND(AVG(po.Is_OTIF) * 100, 2) AS OTIF_Score,
        ROUND(100.0 - ((SUM(po.Defect_Qty) * 100.0) / NULLIF(SUM(po.Delivered_Qty), 0)), 2) AS Quality_Score,
        ROUND(100.0 - GREATEST(0, (SUM(po.Purchase_Price_Variance) * 100.0) / NULLIF(SUM(po.Total_PO_Amount), 0) * 5), 2) AS Price_Discipline_Score,
        ROUND(GREATEST(0, 100.0 - (AVG(po.Delivery_Delay_Days) * 10)), 2) AS Lead_Time_Score
    FROM dim_suppliers s
    JOIN fact_purchase_orders po ON s.Supplier_ID = po.Supplier_ID
    GROUP BY s.Supplier_ID, s.Supplier_Name, s.Vendor_Tier
)
SELECT 
    Supplier_ID,
    Supplier_Name,
    Vendor_Tier,
    OTIF_Score,
    Quality_Score,
    Price_Discipline_Score,
    Lead_Time_Score,
    -- Weighted Composite Score (out of 100)
    ROUND(
        (OTIF_Score * 0.40) + 
        (Quality_Score * 0.30) + 
        (Price_Discipline_Score * 0.20) + 
        (Lead_Time_Score * 0.10), 1
    ) AS Composite_Supplier_Index,
    CASE 
        WHEN ((OTIF_Score * 0.40) + (Quality_Score * 0.30) + (Price_Discipline_Score * 0.20) + (Lead_Time_Score * 0.10)) >= 88 THEN 'Tier 1 - Preferred Partner'
        WHEN ((OTIF_Score * 0.40) + (Quality_Score * 0.30) + (Price_Discipline_Score * 0.20) + (Lead_Time_Score * 0.10)) >= 78 THEN 'Tier 2 - Qualified Vendor'
        ELSE 'Tier 3 - Performance Watchlist / Re-negotiate'
    END AS Performance_Status
FROM SupplierMetrics
ORDER BY Composite_Supplier_Index DESC;


-- QUERY 4: PURCHASE PRICE VARIANCE (PPV) COST SAVINGS OPPORTUNITY
-- Business Purpose: Identify vendors charging above contracted prices (leakage)
SELECT 
    s.Supplier_Name,
    it.Item_Name,
    COUNT(po.PO_Number) AS Orders_Count,
    SUM(po.Ordered_Qty) AS Total_Units_Ordered,
    it.Contracted_Unit_Price,
    ROUND(AVG(po.Actual_Unit_Price), 2) AS Avg_Actual_Unit_Price,
    ROUND(SUM(po.Purchase_Price_Variance), 2) AS Total_PPV_Cost_Leakage_USD
FROM fact_purchase_orders po
JOIN dim_suppliers s ON po.Supplier_ID = s.Supplier_ID
JOIN dim_procurement_items it ON po.Item_ID = it.Item_ID
WHERE po.Purchase_Price_Variance > 0
GROUP BY s.Supplier_Name, it.Item_Name, it.Contracted_Unit_Price
ORDER BY Total_PPV_Cost_Leakage_USD DESC;
