# Retail Data Warehouse ETL & Optimization Project

## Project Overview
This project demonstrates an end-to-end Data Engineering pipeline. It extracts heterogeneous sales datasets (CSV, JSON, and Partner sheets), transforms and standardizes them using Python, loads them into a PostgreSQL Star Schema database, and applies warehouse optimizations.

## Tech Stack
* **Language:** Python 3 (Pandas)
* **Database:** PostgreSQL (pgAdmin 4)
* **Modeling:** Star Schema OLAP Architecture

## Key Features
* **ETL Pipeline:** Consolidated multi-channel data, handled missing data metrics, and standardized timestamps.
* **Database Optimization:** Implemented table partitioning by year, indexing on key dimensions, and created Materialized Views.
* **Performance Evaluation:** Utilized `EXPLAIN ANALYZE` to prove that Materialized Views achieved a **100x speed increase** for OLAP reporting queries compared to raw sequential scans.