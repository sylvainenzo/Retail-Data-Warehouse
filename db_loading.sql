COPY Staging_Sales_Cleaned (
    transaction_id, standard_date, product_id, quantity, unit_price, total_amount, channel
)
FROM '/Users/markbkiunga/Development/USIU/2.2/Retail-Data-Warehouse/cleaned_warehouse_ready_data.csv'
DELIMITER ',' 
CSV HEADER;

-- 
-- 
--

-- 1. Create a default Customer profile (since CSV lacks customer details)
INSERT INTO Dim_Customer (customer_identifier, customer_name, segment)
VALUES ('GEN-001', 'General Customer', 'Standard')
ON CONFLICT (customer_identifier) DO NOTHING;

-- 2. Seed unique dates from your staging data
INSERT INTO Dim_Date (date_key, full_date, day, month, year)
SELECT DISTINCT
    TO_CHAR(standard_date, 'YYYYMMDD')::INTEGER,
    standard_date,
    EXTRACT(DAY FROM standard_date)::INTEGER,
    EXTRACT(MONTH FROM standard_date)::INTEGER,
    EXTRACT(YEAR FROM standard_date)::INTEGER
FROM Staging_Sales_Cleaned
ON CONFLICT (date_key) DO NOTHING;

-- 3. Seed unique products (generating a clean temporary product name/category)
INSERT INTO Dim_Product (product_id, product_name, category)
SELECT DISTINCT 
    product_id, 
    'Product ' || product_id AS product_name, -- e.g., "Product P102"
    'General' AS category                     -- Default category grouping
FROM Staging_Sales_Cleaned
ON CONFLICT (product_id) DO NOTHING;

-- 4. Seed unique channels and assign regional fallbacks
INSERT INTO Dim_Channel (channel_name, region)
SELECT DISTINCT 
    channel, 
    CASE 
        WHEN channel = 'Online' THEN 'Global'
        WHEN channel = 'Partner' THEN 'Coast Region'
        ELSE 'Nairobi CBD'
    END AS region
FROM Staging_Sales_Cleaned;

-- 
-- 
-- 

INSERT INTO Fact_Sales (transaction_id, date_key, product_key, channel_key, customer_key, quantity, unit_price, total_amount)
SELECT 
    s.transaction_id,
    TO_CHAR(s.standard_date, 'YYYYMMDD')::INTEGER AS date_key,
    p.product_key,
    ch.channel_key,
    (SELECT customer_key FROM Dim_Customer WHERE customer_identifier = 'GEN-001') AS customer_key,
    
    -- 1. DYNAMIC QUANTITY CALCULATION (Fallback for Partner Sales)
    COALESCE(
        s.quantity, 
        -- If quantity is null, calculate it: total_amount / unit_price
        ROUND(s.total_amount / COALESCE(s.unit_price, 1000.00)) -- Defaults to 1000 base price if both are null
    ) AS quantity,
    
    -- 2. DYNAMIC UNIT PRICE CALCULATION
    COALESCE(
        s.unit_price, 
        -- If unit_price is null, calculate it: total_amount / quantity
        ROUND(s.total_amount / COALESCE(s.quantity, 1)) 
    ) AS unit_price,
    
    s.total_amount
FROM Staging_Sales_Cleaned s
JOIN Dim_Product p ON s.product_id = p.product_id
JOIN Dim_Channel ch ON s.channel = ch.channel_name;

--
--
--

SELECT 
    f.transaction_id,
    d.full_date,
    p.product_name,
    ch.channel_name,
    ch.region,
    f.total_amount
FROM Fact_Sales f
JOIN Dim_Date d ON f.date_key = d.date_key
JOIN Dim_Product p ON f.product_key = p.product_key
JOIN Dim_Channel ch ON f.channel_key = ch.channel_key
LIMIT 5;