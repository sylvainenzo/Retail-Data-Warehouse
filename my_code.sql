-- Create Dimension Tables
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT
);

CREATE TABLE Dim_Product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50)
);

CREATE TABLE Dim_Channel (
    channel_key SERIAL PRIMARY KEY,
    channel_name VARCHAR(50)
);

-- Create Fact Table
CREATE TABLE Fact_Sales (
    sales_id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(50),
    date_key INT REFERENCES Dim_Date(date_key),
    product_key INT REFERENCES Dim_Product(product_key),
    channel_key INT REFERENCES Dim_Channel(channel_key),
    quantity NUMERIC,
    unit_price NUMERIC,
    total_amount NUMERIC
);