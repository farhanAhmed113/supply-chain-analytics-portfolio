-- =====================================================================
-- PROJECT 1: INVENTORY MANAGEMENT & STOCK OPTIMIZATION DASHBOARD
-- Dialect: Standard ANSI SQL (Compatible with PostgreSQL, MySQL, SQL Server, SQLite)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. TABLE CREATION (DDL)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS dim_products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL,
    Product_Name VARCHAR(150) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Unit_Cost DECIMAL(10,2) NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL,
    Lead_Time_Days INT NOT NULL,
    Supplier_ID VARCHAR(20) NOT NULL,
    Target_Service_Level DECIMAL(4,2) DEFAULT 0.95
);

CREATE TABLE IF NOT EXISTS dim_warehouses (
    Warehouse_ID VARCHAR(20) PRIMARY KEY,
    Warehouse_Name VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_inventory (
    Warehouse_ID VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Stock_On_Hand INT NOT NULL,
    Reserved_Stock INT NOT NULL,
    Available_Stock INT NOT NULL,
    Safety_Stock INT NOT NULL,
    Reorder_Point INT NOT NULL,
    MOQ INT NOT NULL,
    Annual_Holding_Cost DECIMAL(12,2) NOT NULL,
    Last_Audit_Date DATE NOT NULL,
    PRIMARY KEY (Warehouse_ID, Product_ID),
    FOREIGN KEY (Product_ID) REFERENCES dim_products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES dim_warehouses(Warehouse_ID)
);

CREATE TABLE IF NOT EXISTS fact_sales_orders (
    Order_ID VARCHAR(50) PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Warehouse_ID VARCHAR(20) NOT NULL,
    Quantity_Sold INT NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL,
    Sales_Amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (Product_ID) REFERENCES dim_products(Product_ID),
    FOREIGN KEY (Warehouse_ID) REFERENCES dim_warehouses(Warehouse_ID)
);


-- ---------------------------------------------------------------------
-- 2. CORE BUSINESS KPIS & REPORTING QUERIES
-- ---------------------------------------------------------------------

-- QUERY 1: EXECUTIVE INVENTORY VALUATION & CAPITAL TIED UP
-- Business Purpose: Identify working capital tied up in warehouses by product category
SELECT 
    p.Category,
    COUNT(DISTINCT p.Product_ID) AS Total_SKUs,
    SUM(i.Stock_On_Hand) AS Total_Units_In_Stock,
    ROUND(SUM(i.Stock_On_Hand * p.Unit_Cost), 2) AS Total_Inventory_Valuation_USD,
    ROUND(SUM(i.Annual_Holding_Cost), 2) AS Total_Annual_Holding_Cost_USD,
    ROUND(AVG(p.Lead_Time_Days), 1) AS Avg_Supplier_Lead_Time_Days
FROM fact_inventory i
JOIN dim_products p ON i.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Inventory_Valuation_USD DESC;


-- QUERY 2: STOCK HEALTH CLASSIFICATION & ACTION LIST
-- Business Purpose: Classify every SKU-Warehouse node into actionable inventory tiers:
-- 1. Stockout: Stock is 0 (Immediate sales loss)
-- 2. Critical: Below Safety Stock (High probability of stockout before supplier arrives)
-- 3. Reorder Needed: Stock <= Reorder Point (Time to trigger replenishment PO)
-- 4. Healthy: Stock between ROP and 2.5x ROP
-- 5. Overstocked: Stock > 2.5x ROP (Excess working capital and holding costs)
WITH InventoryHealth AS (
    SELECT 
        w.Warehouse_Name,
        p.Product_ID,
        p.SKU,
        p.Product_Name,
        p.Category,
        i.Available_Stock,
        i.Safety_Stock,
        i.Reorder_Point,
        i.MOQ,
        CASE 
            WHEN i.Available_Stock = 0 THEN '1. Stockout'
            WHEN i.Available_Stock < i.Safety_Stock THEN '2. Critical (Below Safety Stock)'
            WHEN i.Available_Stock <= i.Reorder_Point THEN '3. Reorder Needed'
            WHEN i.Available_Stock > (i.Reorder_Point * 2.5) THEN '5. Overstocked'
            ELSE '4. Healthy'
        END AS Stock_Status
    FROM fact_inventory i
    JOIN dim_products p ON i.Product_ID = p.Product_ID
    JOIN dim_warehouses w ON i.Warehouse_ID = w.Warehouse_ID
)
SELECT 
    Stock_Status,
    COUNT(*) AS SKU_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_inventory), 2) AS Percent_Of_Total
FROM InventoryHealth
GROUP BY Stock_Status
ORDER BY Stock_Status;


-- QUERY 3: ABC INVENTORY ANALYSIS (PARETO 80/20 RULE)
-- Business Purpose: Categorize items by revenue contribution:
-- Class A: Top 70% of total revenue (~20% of SKUs - high focus)
-- Class B: Next 20% of total revenue (~30% of SKUs - moderate focus)
-- Class C: Remaining 10% of total revenue (~50% of SKUs - low focus / automate)
WITH ProductSalesSummary AS (
    SELECT 
        Product_ID,
        SUM(Quantity_Sold) AS Total_Units_Sold,
        SUM(Sales_Amount) AS Total_Revenue
    FROM fact_sales_orders
    GROUP BY Product_ID
),
CumulativeRevenueCTE AS (
    SELECT 
        p.Product_ID,
        p.Product_Name,
        p.Category,
        p.Unit_Cost,
        p.Unit_Price,
        COALESCE(ps.Total_Revenue, 0) AS Total_Revenue,
        COALESCE(ps.Total_Units_Sold, 0) AS Total_Units_Sold,
        SUM(ps.Total_Revenue) OVER () AS Grand_Total_Revenue,
        SUM(ps.Total_Revenue) OVER (
            ORDER BY ps.Total_Revenue DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Running_Cumulative_Revenue
    FROM dim_products p
    LEFT JOIN ProductSalesSummary ps ON p.Product_ID = ps.Product_ID
)
SELECT 
    Product_ID,
    Product_Name,
    Category,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND((Running_Cumulative_Revenue / Grand_Total_Revenue) * 100, 2) AS Cumulative_Revenue_Pct,
    CASE 
        WHEN (Running_Cumulative_Revenue / Grand_Total_Revenue) * 100 <= 70 THEN 'Class A'
        WHEN (Running_Cumulative_Revenue / Grand_Total_Revenue) * 100 <= 90 THEN 'Class B'
        ELSE 'Class C'
    END AS ABC_Classification
FROM CumulativeRevenueCTE
ORDER BY Total_Revenue DESC;


-- QUERY 4: INVENTORY VELOCITY (TURNOVER RATIO & DAYS SALES OF INVENTORY)
-- Business Purpose: Measure how fast inventory cycles through warehouses.
-- High Turnover = High efficiency; Low Turnover = Dead stock / sluggish capital
WITH AnnualSalesByProduct AS (
    SELECT 
        Product_ID,
        SUM(Quantity_Sold) AS Annual_Units_Sold,
        SUM(Sales_Amount) AS Annual_Sales_USD,
        COUNT(DISTINCT Order_Date) AS Days_With_Sales
    FROM fact_sales_orders
    GROUP BY Product_ID
),
InventoryAggregated AS (
    SELECT 
        Product_ID,
        SUM(Stock_On_Hand) AS Total_Stock_On_Hand,
        SUM(Available_Stock) AS Total_Available_Stock
    FROM fact_inventory
    GROUP BY Product_ID
)
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Unit_Cost,
    inv.Total_Stock_On_Hand,
    sales.Annual_Units_Sold,
    ROUND((sales.Annual_Units_Sold * p.Unit_Cost), 2) AS Cost_Of_Goods_Sold_COGS,
    ROUND((inv.Total_Stock_On_Hand * p.Unit_Cost), 2) AS Current_Inventory_Value,
    -- Inventory Turnover Ratio = COGS / Current Inventory Value
    ROUND(
        CASE 
            WHEN (inv.Total_Stock_On_Hand * p.Unit_Cost) > 0 
            THEN (sales.Annual_Units_Sold * p.Unit_Cost) / (inv.Total_Stock_On_Hand * p.Unit_Cost)
            ELSE 0 
        END, 2
    ) AS Inventory_Turnover_Ratio,
    -- Days Sales of Inventory (DSI) = 365 / Inventory Turnover
    ROUND(
        CASE 
            WHEN sales.Annual_Units_Sold > 0 
            THEN (inv.Total_Stock_On_Hand * 365.0) / sales.Annual_Units_Sold
            ELSE 999 
        END, 1
    ) AS Days_Sales_Of_Inventory_DSI,
    CASE 
        WHEN (sales.Annual_Units_Sold * 1.0 / NULLIF(inv.Total_Stock_On_Hand, 0)) >= 6.0 THEN 'Fast-Moving'
        WHEN (sales.Annual_Units_Sold * 1.0 / NULLIF(inv.Total_Stock_On_Hand, 0)) >= 2.5 THEN 'Medium-Moving'
        ELSE 'Slow-Moving'
    END AS Movement_Velocity_Tier
FROM dim_products p
JOIN InventoryAggregated inv ON p.Product_ID = inv.Product_ID
JOIN AnnualSalesByProduct sales ON p.Product_ID = sales.Product_ID
ORDER BY Inventory_Turnover_Ratio DESC;


-- QUERY 5: AUTOMATED REORDER & PURCHASE ORDER RECOMMENDATION
-- Business Purpose: Generate the exact Purchase Orders required right now.
-- Calculation: If Available_Stock <= Reorder_Point, Recommend Max(MOQ, (2 * ROP - Available_Stock))
SELECT 
    w.Warehouse_Name,
    p.Supplier_ID,
    p.Product_ID,
    p.SKU,
    p.Product_Name,
    p.Lead_Time_Days,
    i.Available_Stock,
    i.Safety_Stock,
    i.Reorder_Point,
    i.MOQ,
    -- Recommended Order Quantity
    CASE 
        WHEN i.Available_Stock <= i.Reorder_Point 
        THEN 
            CASE 
                WHEN ((i.Reorder_Point * 2) - i.Available_Stock) < i.MOQ THEN i.MOQ
                ELSE ((i.Reorder_Point * 2) - i.Available_Stock)
            END
        ELSE 0 
    END AS Recommended_Order_Qty,
    -- Estimated Order Cost
    ROUND(
        (CASE 
            WHEN i.Available_Stock <= i.Reorder_Point 
            THEN 
                CASE 
                    WHEN ((i.Reorder_Point * 2) - i.Available_Stock) < i.MOQ THEN i.MOQ
                    ELSE ((i.Reorder_Point * 2) - i.Available_Stock)
                END
            ELSE 0 
        END) * p.Unit_Cost, 2
    ) AS Estimated_Purchase_Cost_USD
FROM fact_inventory i
JOIN dim_products p ON i.Product_ID = p.Product_ID
JOIN dim_warehouses w ON i.Warehouse_ID = w.Warehouse_ID
WHERE i.Available_Stock <= i.Reorder_Point
ORDER BY (i.Safety_Stock - i.Available_Stock) DESC, Estimated_Purchase_Cost_USD DESC;
