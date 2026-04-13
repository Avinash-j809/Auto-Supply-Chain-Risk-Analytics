-- Create the database

CREATE DATABASE auto_supply_chain;
GO

-- Use it
USE auto_supply_chain;
select * from dbo.defects_data;
select * from dbo.order_data;
select * from dbo.supplier_risk_scores_data;

USE auto_supply_chain;

SELECT 'supplier_risk_scores_data' AS table_name, COUNT(*) AS row_count FROM dbo.supplier_risk_scores_data
UNION ALL
SELECT 'order_data', COUNT(*) FROM dbo.order_data
UNION ALL
SELECT 'defects_data', COUNT(*) FROM dbo.defects_data;

USE auto_supply_chain;

SELECT 
    o.supplier_id,
    s.supplier_name,
    s.country,
    s.tier,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.is_delayed = 0 THEN 1 ELSE 0 END) AS on_time_orders,
    ROUND(100.0 * SUM(CASE WHEN o.is_delayed = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS otd_rate_pct
FROM dbo.order_data o
JOIN dbo.supplier_risk_scores_data s ON o.supplier_id = s.supplier_id
GROUP BY o.supplier_id, s.supplier_name, s.country, s.tier
ORDER BY otd_rate_pct ASC;


-- Query 2: Average Delay by Part Category
-- Tells us which AUTO COMPONENTS have the worst delivery delays
-- Helps procurement know which parts to keep extra safety stock for

SELECT 
    part_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 2) AS avg_delay_days,
    ROUND(100.0 * SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS delay_rate_pct
FROM dbo.order_data
GROUP BY part_category
ORDER BY avg_delay_days DESC;


-- Query 3: Top 10 Highest Risk Suppliers
-- This is the main output of the entire project
-- Combines delay performance + quality complaints into one risk score
-- These are the suppliers procurement should audit first

SELECT TOP 10
    supplier_name,
    country,
    tier,
    part_category,
    total_orders,
    ROUND(avg_delay, 2) AS avg_delay_days,
    ROUND(delay_rate * 100, 1) AS delay_rate_pct,
    defect_count,
    risk_score,
    risk_category
FROM dbo.supplier_risk_scores_data
ORDER BY risk_score DESC;

-- Query 4: Monthly Order Volume and Delay Trend
-- Shows whether delivery performance is getting better or worse over time
-- Useful for the trend line chart in Power BI dashboard

SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(100.0 * SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS delay_rate_pct,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 2) AS avg_delay_days
FROM dbo.order_data
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;

-- Query 5: Delay Rate by Shipping Mode
-- Tells us whether the transport method affects delivery punctuality
-- Helps decide which shipping mode is most reliable

SELECT 
    shipping_mode,
    COUNT(*) AS total_shipments,
    ROUND(100.0 * SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS delay_rate_pct,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 2) AS avg_delay_days,
    ROUND(AVG(CAST(order_value AS FLOAT)), 2) AS avg_order_value
FROM dbo.order_data
GROUP BY shipping_mode
ORDER BY delay_rate_pct DESC;

-- Query 6: Supplier Risk Summary by Country
-- Shows which countries have the most concentrated supply chain risk
-- Useful for geographic risk diversification decisions

SELECT 
    country,
    COUNT(*) AS total_suppliers,
    ROUND(AVG(CAST(risk_score AS FLOAT)), 1) AS avg_risk_score,
    SUM(CASE WHEN risk_category = 'High Risk'   THEN 1 ELSE 0 END) AS high_risk_suppliers,
    SUM(CASE WHEN risk_category = 'Medium Risk' THEN 1 ELSE 0 END) AS medium_risk_suppliers,
    SUM(CASE WHEN risk_category = 'Low Risk'    THEN 1 ELSE 0 END) AS low_risk_suppliers,
    SUM(total_orders) AS total_orders_handled
FROM dbo.supplier_risk_scores_data
GROUP BY country
ORDER BY avg_risk_score DESC;