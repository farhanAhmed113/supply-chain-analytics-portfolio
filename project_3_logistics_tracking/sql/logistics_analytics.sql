-- =====================================================================
-- PROJECT 3: LOGISTICS & SHIPMENT TRACKING ANALYSIS
-- Dialect: Standard ANSI SQL (PostgreSQL, MySQL, SQL Server, SQLite)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABLE CREATION (DDL)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dim_carriers (
    Carrier_ID VARCHAR(20) PRIMARY KEY,
    Carrier_Name VARCHAR(100) NOT NULL,
    Transport_Mode VARCHAR(50) NOT NULL,
    Base_Rate_Per_Mile DECIMAL(6,2) NOT NULL,
    Target_OTD_SLA DECIMAL(4,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_routes (
    Route_ID VARCHAR(20) PRIMARY KEY,
    Origin VARCHAR(100) NOT NULL,
    Destination VARCHAR(100) NOT NULL,
    Distance_Miles INT NOT NULL,
    Standard_Transit_Days INT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_shipments (
    Shipment_ID VARCHAR(50) PRIMARY KEY,
    Tracking_Number VARCHAR(50) NOT NULL,
    Carrier_ID VARCHAR(20) NOT NULL,
    Route_ID VARCHAR(20) NOT NULL,
    Ship_Date DATE NOT NULL,
    Est_Delivery_Date DATE NOT NULL,
    Actual_Delivery_Date DATE NOT NULL,
    Actual_Transit_Days INT NOT NULL,
    Delay_Days INT NOT NULL,
    Is_On_Time INT NOT NULL,
    Delivery_Status VARCHAR(50) NOT NULL,
    Delay_Reason VARCHAR(100) NOT NULL,
    Weight_Kg INT NOT NULL,
    Priority VARCHAR(30) NOT NULL,
    Freight_Cost_USD DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Carrier_ID) REFERENCES dim_carriers(Carrier_ID),
    FOREIGN KEY (Route_ID) REFERENCES dim_routes(Route_ID)
);

-- ---------------------------------------------------------------------
-- 2. LOGISTICS KPIS & ROUTE BOTTLENECK QUERIES
-- ---------------------------------------------------------------------

-- QUERY 1: EXECUTIVE CARRIER BENCHMARKING (OTD, DELAYS, AND FREIGHT SPEND)
-- Business Purpose: Measure carrier compliance against contracted On-Time Delivery SLAs
SELECT 
    c.Carrier_ID,
    c.Carrier_Name,
    c.Transport_Mode,
    COUNT(s.Shipment_ID) AS Total_Shipments,
    ROUND(SUM(s.Freight_Cost_USD), 2) AS Total_Freight_Cost_USD,
    ROUND(AVG(s.Freight_Cost_USD), 2) AS Avg_Cost_Per_Shipment,
    ROUND(AVG(s.Is_On_Time) * 100, 2) AS Actual_OTD_Pct,
    ROUND(c.Target_OTD_SLA * 100, 1) AS Target_SLA_Pct,
    ROUND((AVG(s.Is_On_Time) - c.Target_OTD_SLA) * 100, 2) AS SLA_Variance_Pct,
    ROUND(AVG(s.Delay_Days), 2) AS Avg_Delay_Days
FROM dim_carriers c
JOIN fact_shipments s ON c.Carrier_ID = s.Carrier_ID
GROUP BY c.Carrier_ID, c.Carrier_Name, c.Transport_Mode, c.Target_OTD_SLA
ORDER BY Total_Freight_Cost_USD DESC;


-- QUERY 2: ROUTE BOTTLENECK ANALYSIS & LANE PERFORMANCE
-- Business Purpose: Identify geographical shipping lanes experiencing the highest delay rates
SELECT 
    r.Route_ID,
    r.Origin,
    r.Destination,
    r.Distance_Miles,
    r.Standard_Transit_Days,
    COUNT(s.Shipment_ID) AS Total_Dispatched,
    SUM(CASE WHEN s.Is_On_Time = 0 THEN 1 ELSE 0 END) AS Delayed_Shipments,
    ROUND(AVG(s.Is_On_Time) * 100, 1) AS Lane_OTD_Pct,
    ROUND(AVG(s.Delay_Days), 2) AS Avg_Delay_Days,
    ROUND(SUM(s.Freight_Cost_USD), 2) AS Total_Lane_Spend_USD
FROM dim_routes r
JOIN fact_shipments s ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Origin, r.Destination, r.Distance_Miles, r.Standard_Transit_Days
ORDER BY Lane_OTD_Pct ASC;


-- QUERY 3: ROOT CAUSE PARETO ANALYSIS OF SHIPMENT DELAYS
-- Business Purpose: Categorize and prioritize delay drivers to fix operational bottlenecks
WITH DelaySummary AS (
    SELECT 
        Delay_Reason,
        COUNT(*) AS Delay_Incidents,
        SUM(Delay_Days) AS Total_Lost_Days,
        SUM(Freight_Cost_USD) AS Impacted_Freight_Value
    FROM fact_shipments
    WHERE Delay_Reason != 'None'
    GROUP BY Delay_Reason
)
SELECT 
    Delay_Reason,
    Delay_Incidents,
    Total_Lost_Days,
    ROUND(Impacted_Freight_Value, 2) AS Impacted_Freight_Value,
    ROUND((Delay_Incidents * 100.0) / (SELECT SUM(Delay_Incidents) FROM DelaySummary), 2) AS Pct_Of_All_Delays,
    ROUND(
        SUM(Delay_Incidents) OVER (ORDER BY Delay_Incidents DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 
        / (SELECT SUM(Delay_Incidents) FROM DelaySummary), 
        2
    ) AS Cumulative_Pareto_Pct
FROM DelaySummary
ORDER BY Delay_Incidents DESC;


-- QUERY 4: FREIGHT EFFICIENCY & COST PER TON-MILE
-- Business Purpose: Measure economic efficiency across transport modes:
-- Ton-Miles = (Weight in Tons) * (Distance in Miles)
-- Cost per Ton-Mile = Total Freight Cost / Total Ton-Miles
SELECT 
    c.Transport_Mode,
    COUNT(s.Shipment_ID) AS Dispatches,
    ROUND(SUM(s.Freight_Cost_USD), 2) AS Mode_Freight_Cost,
    ROUND(SUM((s.Weight_Kg / 1000.0) * r.Distance_Miles), 2) AS Total_Ton_Miles,
    ROUND(
        SUM(s.Freight_Cost_USD) / NULLIF(SUM((s.Weight_Kg / 1000.0) * r.Distance_Miles), 0), 
        4
    ) AS Cost_Per_Ton_Mile_USD
FROM fact_shipments s
JOIN dim_carriers c ON s.Carrier_ID = c.Carrier_ID
JOIN dim_routes r ON s.Route_ID = r.Route_ID
GROUP BY c.Transport_Mode
ORDER BY Cost_Per_Ton_Mile_USD DESC;


-- QUERY 5: EXPEDITED FREIGHT PREMIUM ANALYSIS (COST OF EMERGENCY SHIPPING)
-- Business Purpose: Calculate the financial premium paid for Expedited and Urgent priority orders
-- versus Standard ground shipping
SELECT 
    Priority,
    COUNT(Shipment_ID) AS Total_Shipments,
    ROUND(SUM(Freight_Cost_USD), 2) AS Total_Spend_USD,
    ROUND(AVG(Freight_Cost_USD), 2) AS Avg_Cost_Per_Shipment,
    ROUND(AVG(Is_On_Time) * 100, 1) AS OTD_Pct,
    ROUND(
        AVG(Freight_Cost_USD) - 
        (SELECT AVG(Freight_Cost_USD) FROM fact_shipments WHERE Priority = 'Standard'), 
        2
    ) AS Premium_Per_Shipment_Over_Standard
FROM fact_shipments
GROUP BY Priority
ORDER BY Avg_Cost_Per_Shipment DESC;
