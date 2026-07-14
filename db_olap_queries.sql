-- Roll up
SELECT 
    p.category, 
    d.year, 
    SUM(f.total_amount) AS total_revenue
FROM Fact_Sales_Partitioned f
JOIN Dim_Product p ON f.product_key = p.product_key
JOIN Dim_Date d ON f.date_key = d.date_key
GROUP BY ROLLUP (p.category, d.year)
ORDER BY p.category NULLS LAST, d.year NULLS LAST;

-- Drill down
SELECT 
    p.category, 
    p.product_name, 
    SUM(f.total_amount) AS total_revenue,
    SUM(f.quantity) AS units_sold
FROM Fact_Sales_Partitioned f
JOIN Dim_Product p ON f.product_key = p.product_key
GROUP BY p.category, p.product_name
ORDER BY p.category, total_revenue DESC;

-- Slice
SELECT 
    p.product_name, 
    SUM(f.total_amount) AS online_revenue
FROM Fact_Sales_Partitioned f
JOIN Dim_Product p ON f.product_key = p.product_key
JOIN Dim_Channel c ON f.channel_key = c.channel_key
WHERE c.channel_name = 'Online' -- The "Slice" filter
GROUP BY p.product_name
ORDER BY online_revenue DESC;

-- Dice
SELECT 
    p.product_name, 
    SUM(f.total_amount) AS diced_revenue
FROM Fact_Sales_Partitioned f
JOIN Dim_Product p ON f.product_key = p.product_key
JOIN Dim_Channel c ON f.channel_key = c.channel_key
JOIN Dim_Date d ON f.date_key = d.date_key
WHERE c.channel_name = 'In-Store'        -- Dimension Filter 1
  AND c.region = 'Nairobi CBD'          -- Dimension Filter 2
  AND d.year = 2003                      -- Dimension Filter 3
GROUP BY p.product_name
ORDER BY diced_revenue DESC;