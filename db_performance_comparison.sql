-- Unoptimized table
EXPLAIN ANALYZE
SELECT 
    p.category, 
    SUM(f.total_amount) AS total_revenue
FROM Fact_Sales f
JOIN Dim_Product p ON f.product_key = p.product_key
WHERE f.date_key BETWEEN 20030101 AND 20030630
GROUP BY p.category;

-- Optimized table
EXPLAIN ANALYZE
SELECT 
    p.category, 
    SUM(f.total_amount) AS total_revenue
FROM Fact_Sales_Partitioned f
JOIN Dim_Product p ON f.product_key = p.product_key
WHERE f.date_key BETWEEN 20030101 AND 20030630
GROUP BY p.category;

-- Materialized View
EXPLAIN ANALYZE
SELECT product_category, SUM(total_revenue)
FROM mv_monthly_sales_summary
WHERE year = 2003 AND month <= 6
GROUP BY product_category;