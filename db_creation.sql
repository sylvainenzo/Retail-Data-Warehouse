-- Drop existing tables to ensure a clean slate
DROP TABLE IF EXISTS Fact_Sales CASCADE;
DROP TABLE IF EXISTS Dim_Customer CASCADE;
DROP TABLE IF EXISTS Dim_Channel CASCADE;
DROP TABLE IF EXISTS Dim_Product CASCADE;
DROP TABLE IF EXISTS Dim_Date CASCADE;
DROP TABLE IF EXISTS Staging_Sales_Cleaned CASCADE;

-- 1. Create Dimension Tables
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL
);

CREATE TABLE Dim_Product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Channel (
    channel_key SERIAL PRIMARY KEY,
    channel_name VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Customer (
    customer_key SERIAL PRIMARY KEY,
    customer_identifier VARCHAR(100) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment VARCHAR(50) NOT NULL
);

-- 2. Create Fact Table
CREATE TABLE Fact_Sales (
    sales_id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(50) NOT NULL,
    date_key INT REFERENCES Dim_Date(date_key),
    product_key INT REFERENCES Dim_Product(product_key),
    channel_key INT REFERENCES Dim_Channel(channel_key),
    customer_key INT REFERENCES Dim_Customer(customer_key),
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL
);

-- 3. Create Staging Table for clean CSV loading
CREATE TABLE Staging_Sales_Cleaned (
    transaction_id VARCHAR(50),
    standard_date DATE,
    product_id VARCHAR(50),
    quantity NUMERIC(12,2),
    unit_price NUMERIC(12,2),
    total_amount NUMERIC(12,2),
    channel VARCHAR(50)
);