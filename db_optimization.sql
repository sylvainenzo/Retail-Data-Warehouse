-- 1. Table partitioning
-- Create a Partitioned Fact Table
CREATE TABLE Fact_Sales_Partitioned (
    sales_id INT,
    transaction_id VARCHAR(50) NOT NULL,
    date_key INT,
    product_key INT,
    channel_key INT,
    customer_key INT,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL
) PARTITION BY RANGE (date_key);

-- Create concrete partition sheets
-- Partition 1: Historical Sales (2003)
CREATE TABLE Fact_Sales_Y2003 PARTITION OF Fact_Sales_Partitioned
    FOR VALUES FROM (20030101) TO (20040101);

-- Partition 2: Historical Sales (2004)
CREATE TABLE Fact_Sales_Y2004 PARTITION OF Fact_Sales_Partitioned
    FOR VALUES FROM (20040101) TO (20050101);

-- Partition 3: Future Online Sales (2025)
CREATE TABLE Fact_Sales_Y2025 PARTITION OF Fact_Sales_Partitioned
    FOR VALUES FROM (20250101) TO (20260101);

-- Default Partition (Catch-all for any other dates)
CREATE TABLE Fact_Sales_Default PARTITION OF Fact_Sales_Partitioned DEFAULT;

-- Ingest all data from your base fact table into the partitioned architecture
INSERT INTO Fact_Sales_Partitioned 
SELECT * FROM Fact_Sales;


-- 2. Matrialized view
CREATE MATERIALIZED VIEW mv_monthly_sales_summary AS
SELECT 
    d.year,
    d.month,
    p.category AS product_category,
    c.channel_name,
    SUM(f.quantity) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue,
    COUNT(f.sales_id) AS total_transactions
FROM Fact_Sales_Partitioned f
JOIN Dim_Date d ON f.date_key = d.date_key
JOIN Dim_Product p ON f.product_key = p.product_key
JOIN Dim_Channel c ON f.channel_key = c.channel_key
GROUP BY d.year, d.month, p.category, c.channel_name;


-- 3. Indexing
CREATE INDEX idx_partition_product ON Fact_Sales_Partitioned (product_key);
CREATE INDEX idx_partition_date ON Fact_Sales_Partitioned (date_key);
-- Speed up queries that filter by year and month on the materialized view
CREATE INDEX idx_mv_sales_date 
ON mv_monthly_sales_summary (year, month);
