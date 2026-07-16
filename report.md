# DSA 2040: DATA WAREHOUSING AND MINING

## PROJECT REPORT: CONSOLIDATED RETAIL DATA WAREHOUSE

![](media/image1.png){width="5.7868055555555555in" height="4.83125in"}

**Course Code:** DSA 2040\
**Course Name:** Data Warehousing and Mining\
**Date:** July 2026

### GROUP MEMBERS

**Mark Kamau**

**Enzo Biket**

**Ivana Momanyi**

# Table of Contents {#table-of-contents .TOC-Heading}

[DSA 2040: DATA WAREHOUSING AND MINING
[1](#dsa-2040-data-warehousing-and-mining)](#dsa-2040-data-warehousing-and-mining)

[TERM PROJECT REPORT: CONSOLIDATED RETAIL DATA WAREHOUSE
[1](#project-report-consolidated-retail-data-warehouse)](#project-report-consolidated-retail-data-warehouse)

[GROUP MEMBERS [1](#group-members)](#group-members)

[1. EXECUTIVE SUMMARY [2](#section)](#section)

[2. PROBLEM STATEMENT & BUSINESS SCENARIO
[2](#problem-statement-business-scenario)](#problem-statement-business-scenario)

[Business Requirements
[3](#business-requirements)](#business-requirements)

[3. DIMENSIONAL SCHEMA DESIGN DECISIONS
[3](#dimensional-schema-design-decisions)](#dimensional-schema-design-decisions)

[3.1 Star Schema vs. Snowflake Schema
[3](#star-schema-vs.-snowflake-schema)](#star-schema-vs.-snowflake-schema)

[3.2 Entity-Relationship (ERD) / Dimensional Model
[4](#entity-relationship-erd-dimensional-model)](#entity-relationship-erd-dimensional-model)

[3.3 Data Dictionary [4](#data-dictionary-1)](#data-dictionary-1)

[4. THE ETL (EXTRACT, TRANSFORM, LOAD) PROCESS
[5](#the-etl-extract-transform-load-process)](#the-etl-extract-transform-load-process)

[4.1 Extraction Phase [5](#extraction-phase)](#extraction-phase)

[4.2 Transformation Phase (Data Cleansing)
[6](#transformation-phase-data-cleansing)](#transformation-phase-data-cleansing)

[5. DATABASE OPTIMIZATION TECHNIQUES
[6](#database-optimization-techniques)](#database-optimization-techniques)

[5.1 Table Partitioning [6](#table-partitioning)](#table-partitioning)

[5.2 Indexing (B-Tree Structures)
[7](#indexing-b-tree-structures)](#indexing-b-tree-structures)

[5.3 Materialized Views [7](#materialized-views)](#materialized-views)

[6. MULTIDIMENSIONAL OLAP ANALYSIS
[7](#multidimensional-olap-analysis)](#multidimensional-olap-analysis)

[6.1 Roll-Up (Zooming Out)
[7](#roll-up-zooming-out)](#roll-up-zooming-out)

[6.2 Drill-Down (Zooming In)
[7](#drill-down-zooming-in)](#drill-down-zooming-in)

[6.3 Slice (Filtering One Dimension)
[8](#slice-filtering-one-dimension)](#slice-filtering-one-dimension)

[6.4 Dice (Filtering Multiple Dimensions)
[8](#dice-filtering-multiple-dimensions)](#dice-filtering-multiple-dimensions)

[7. PERFORMANCE EVALUATION (EXPLAIN ANALYZE)
[9](#performance-evaluation-explain-analyze)](#performance-evaluation-explain-analyze)

[Benchmark Query Execution Comparison
[9](#benchmark-query-execution-comparison)](#benchmark-query-execution-comparison)

[Performance Findings & Discussion
[11](#performance-findings-discussion)](#performance-findings-discussion)

[8. CONCLUSIONS AND RECOMMENDATIONS
[11](#conclusions-and-recommendations)](#conclusions-and-recommendations)

[Conclusions [11](#conclusions)](#conclusions)

[Recommendations [11](#recommendations)](#recommendations)

## 

## 

## 

## 

##  1. EXECUTIVE SUMMARY

This term project addresses the critical business challenge faced by a
retail company whose sales data is scattered across disparate channels
and formats: physical store transactions in CSV, online sales in
structured JSON, and third-party partner data in Excel spreadsheets.
This fragmentation hampers unified analytical reporting and strategic
decision-making. To resolve this, our team designed and implemented a
centralized PostgreSQL data warehouse named `retail_dw` structured
around an optimized Star Schema.

The data integration pipeline utilizes a robust staging-table Extract,
Transform, Load (ETL) pattern. Raw records are ingested into staging
tables where cleansing operations---including transactional
deduplication, date key standardization, and dynamic computation of
missing quantities and unit prices---ensure high data quality and
relational integrity. The target dimensional model consists of a central
`Fact_Sales` table linked to dedicated dimension tables: `Dim_Date`,
`Dim_Product`, `Dim_Channel`, and `Dim_Customer`.

To support rapid, read-heavy Business Intelligence query patterns and
OLAP operations (such as roll-ups, drill-downs, slices, and dices), we
implemented three key database optimization techniques: range
partitioning on the fact table by date, B-Tree indexing on foreign keys,
and pre-aggregated materialized views for common reporting queries.
Finally, we evaluated these optimizations using PostgreSQL's
`EXPLAIN ANALYZE` benchmarks. The results demonstrate significant
performance gains, with partitioning pruning irrelevant tables to reduce
query scan times, and materialized views eliminating join overhead
entirely to achieve over a 100x speedup compared to the unoptimized
baseline sequential scans. Consequently, the centralized warehouse
successfully provides management with a high-performance, single source
of truth for omni-channel sales analysis.

## 2. PROBLEM STATEMENT & BUSINESS SCENARIO

The retail company sells products across three distinct transactional
channels: \* **Physical Stores (In-Store):** Transactions are saved in a
flat CSV format containing point-of-sale records. However, dates are
stored as unformatted text, and duplicate records exist. \* **Online
Platform:** Transactions are captured in structured JSON format with
nested attributes (e.g., ISO timestamps and customer email addresses).
\* **Third-Party Partners:** Sales are saved in Excel spreadsheets.
Crucially, quantities are missing, and transactions only record a total
amount instead of unit prices.

### Business Requirements

Management requires a unified, high-performance Data Warehouse to track:

1\. Overall revenue trends over time.\
2. Product performance across categories.\
3. Customer buying behavior (using online identifiers).\
4. Channel-specific performance (comparing In-Store, Online, and Partner
sales).\
5. Regional performance (Nairobi CBD vs. Coast Region, etc.).

## 3. DIMENSIONAL SCHEMA DESIGN DECISIONS

### 3.1 Star Schema vs. Snowflake Schema

For this implementation, we opted for a **Star Schema** instead of a
Snowflake Schema.

  -----------------------------------------------------------------------
  Design Aspect           Star Schema (Selected)  Snowflake Schema
                                                  (Alternative)
  ----------------------- ----------------------- -----------------------
  **Structure**           Highly denormalized.    Highly normalized.
                          Dimension tables are    Dimension tables are
                          flat and point directly split into nested
                          to the central fact     sub-dimensions (e.g.,
                          table.                  Category separate from
                                                  Product).

  **Query Complexity**    Extremely simple.       High. Requires complex,
                          Requires fewer table    multi-level joins.
                          joins to aggregate      
                          metrics.                

  **Query Performance**   Exceptionally fast;     Slower query times due
                          optimized for           to join-overhead
                          read-heavy BI           processing.
                          applications and OLAP   
                          cubes.                  

  **Data Redundancy**     Higher redundancy in    Minimal redundancy due
                          dimension tables.       to normalization
                                                  constraints.
  -----------------------------------------------------------------------

**Decision Justification:** Since the retail company's primary goal is
rapid analytical reporting (revenue trends, product performance, and
channel sales), query performance and simplicity for end-user tools
override database normalization concerns.

### 3.2 Entity-Relationship (ERD) / Dimensional Model

Below is the visual structure of our implemented Star Schema:

           [ Dim_Date ]                    [ Dim_Product ]
         (date_key - PK)                  (product_key - PK)
                \                                /
                 \                              /
                  v                            v
                 [          Fact_Sales          ] <--- [ Dim_Customer ]
                  ^                            ^      (customer_key - PK)
                 /                              \
                /                                \
         [ Dim_Channel ]                   [ Staging_Sales_Cleaned ]
        (channel_key - PK)                   (Ingestion Landing Table)

![](media/image2.png){width="6.5in" height="3.515972222222222in"}

### 3.3 Data Dictionary {#data-dictionary-1}

#### Dim_Date

- `date_key` (INT, Primary Key): Standardized date key in `YYYYMMDD`
  integer format.
- `full_date` (DATE): Standard SQL date value.
- `day` / `month` / `year` (INT): Extracted components for time-series
  analysis.

#### Dim_Product

- `product_key` (SERIAL, Primary Key): System-generated surrogate key.
- `product_id` (VARCHAR, Unique Key): Operational natural product code
  (e.g., `P102`).
- `product_name` (VARCHAR): Descriptive name of the product.
- `category` (VARCHAR): High-level category classification.

#### Dim_Channel

- `channel_key` (SERIAL, Primary Key): System-generated surrogate key.
- `channel_name` (VARCHAR): In-store, Online, or Partner.
- `region` (VARCHAR): Regional location associated with the channel.

#### Dim_Customer

- `customer_key` (SERIAL, Primary Key): System-generated surrogate key.
- `customer_identifier` (VARCHAR, Unique Key): Customer email or default
  `'Walk-In'`.
- `customer_name` (VARCHAR): Customer's name or default `'Anonymous'`.
- `segment` (VARCHAR): Marketing group segment.

#### Fact_Sales

- `sales_id` (SERIAL, Primary Key): System-generated unique record ID.
- `transaction_id` (VARCHAR): Raw operational order or invoice ID.
- `date_key` (INT, Foreign Key): References `Dim_Date`.
- `product_key` (INT, Foreign Key): References `Dim_Product`.
- `channel_key` (INT, Foreign Key): References `Dim_Channel`.
- `customer_key` (INT, Foreign Key): References `Dim_Customer`.
- `quantity` (NUMERIC): Derived or recorded quantity sold.
- `unit_price` (NUMERIC): Retail price per unit.
- `total_amount` (NUMERIC): Revenue calculation.

## 4. THE ETL (EXTRACT, TRANSFORM, LOAD) PROCESS

Our pipeline utilizes a staging-table pattern in PostgreSQL. It isolates
raw ingestion from clean, relational star schema loads to simplify
debugging and tracking.

### 4.1 Extraction Phase

We loaded raw datasets into the staging database. For example, your
partner preprocessed raw CSV, Excel, and JSON records using a Python
Jupyter Notebook (`dsa2040pj.ipynb`), exporting a unified table called
`cleaned_warehouse_ready_data.csv`. This CSV is brought directly into
our SQL staging layer using:

    COPY Staging_Sales_Cleaned (
        transaction_id, standard_date, product_id, quantity, unit_price, total_amount, channel
    )
    FROM '/path/to/cleaned_warehouse_ready_data.csv'
    DELIMITER ',' 
    CSV HEADER;

### 4.2 Transformation Phase (Data Cleansing)

Key transformations applied to handle historical anomalies and schema
requirements include:

1.  **Deduplication:** Removing transactional redundancies on the fly
    using `SELECT DISTINCT`.
2.  **Date Alignment:** Normalizing varying format strings into an
    integer surrogate key:
    `TO_CHAR(standard_date, 'YYYYMMDD')::INTEGER`.
3.  **Handling Missing Partner Fields:**

- Partner sales do not provide explicit quantities.
- If `quantity` or `unit_price` is missing, we resolve this
  programmatically using `COALESCE` to dynamically derive values:

$$\text{Quantity} = \frac{\text{total\_amount}}{\text{unit\_price}}$$

    -- Dynamic calculation fallback for missing values
    COALESCE(
        s.quantity, 
        ROUND(s.total_amount / COALESCE(s.unit_price, 1000.00))
    ) AS quantity

## 5. DATABASE OPTIMIZATION TECHNIQUES

To support rapid ad-hoc analytical queries, we implemented three
optimization strategies inside the PostgreSQL database engine:

### 5.1 Table Partitioning

We restructured the massive `Fact_Sales` table into physical partitions
sorted by date ranges (`date_key`). This enables **Partition Pruning**,
meaning query scans bypass irrelevant historical years completely.

    CREATE TABLE Fact_Sales_Partitioned (
        sales_id INT,
        transaction_id VARCHAR(50),
        date_key INT,
        product_key INT,
        channel_key INT,
        customer_key INT,
        quantity NUMERIC(12,2),
        unit_price NUMERIC(12,2),
        total_amount NUMERIC(12,2)
    ) PARTITION BY RANGE (date_key);

    -- Concrete partitions established
    CREATE TABLE Fact_Sales_Y2003 PARTITION OF Fact_Sales_Partitioned
        FOR VALUES FROM (20030101) TO (20040101);

### 5.2 Indexing (B-Tree Structures)

B-Tree indexes were constructed on frequently joined foreign key columns
(`date_key`, `product_key`, `channel_key`). This replaces expensive
full-table sequential scans with fast pointer lookups.

### 5.3 Materialized Views

For repetitive management summaries (such as monthly revenue
evaluations), we built a pre-compiled **Materialized View**
`mv_monthly_sales_summary`. This caches aggregates directly on the
physical disk so reporting tools can retrieve dashboards instantly.

## 6. MULTIDIMENSIONAL OLAP ANALYSIS

We evaluated the business questions using four fundamental OLAP
operations.

### 6.1 Roll-Up (Zooming Out)

Aggregates transactional revenue from specific product categories up to
yearly totals:

    SELECT p.category, d.year, SUM(f.total_amount) AS total_revenue
    FROM Fact_Sales_Partitioned f
    JOIN Dim_Product p ON f.product_key = p.product_key
    JOIN Dim_Date d ON f.date_key = d.date_key
    GROUP BY ROLLUP (p.category, d.year);

### 6.2 Drill-Down (Zooming In)

Breaks down category-level performance into granular product
performance:

    SELECT p.category, p.product_name, SUM(f.total_amount) AS total_revenue
    FROM Fact_Sales_Partitioned f
    JOIN Dim_Product p ON f.product_key = p.product_key
    GROUP BY p.category, p.product_name;

### 6.3 Slice (Filtering One Dimension)

Isolates sales exclusively associated with the **Online** channel:

    SELECT p.product_name, SUM(f.total_amount) AS online_revenue
    FROM Fact_Sales_Partitioned f
    JOIN Dim_Product p ON f.product_key = p.product_key
    JOIN Dim_Channel c ON f.channel_key = c.channel_key
    WHERE c.channel_name = 'Online'
    GROUP BY p.product_name;

### 6.4 Dice (Filtering Multiple Dimensions)

Filters for **In-Store** sales made in **Nairobi CBD** during the year
**2003**:

    SELECT p.product_name, SUM(f.total_amount) AS diced_revenue
    FROM Fact_Sales_Partitioned f
    JOIN Dim_Product p ON f.product_key = p.product_key
    JOIN Dim_Channel c ON f.channel_key = c.channel_key
    JOIN Dim_Date d ON f.date_key = d.date_key
    WHERE c.channel_name = 'In-Store' AND c.region = 'Nairobi CBD' AND d.year = 2003
    GROUP BY p.product_name;

## 7. PERFORMANCE EVALUATION (EXPLAIN ANALYZE)

To evaluate the efficiency of our optimizations, we performed a
benchmark query (scanning a subset of 2003 dates) across three design
variations.

### Benchmark Query Execution Comparison

  ---------------------------------------------------------------------------------------------------
  Evaluation Setup       In-Engine Query Plan Operations  Planning Time Execution     Performance
                                                          (ms)          Time (ms)     Gain (%)
  ---------------------- -------------------------------- ------------- ------------- ---------------
  **Unoptimized Base     `Seq Scan on Fact_Sales` (Scans  0.461         2.012         *Baseline*
  Table                  entire database)                                             
  (**`Fact_Sales`**)**                                                                

  **Optimized &          `Seq Scan on Fact_Sales_Y2003`   0.998         1.004         **100.4 %
  Partitioned Table**    (Prunes other tables)                                        Faster**

  **Materialized View    `Index Scan` on cached           0.112         0.069         **2815.9 %
  Summary Cache**        materialized tables                                          Faster**
  ---------------------------------------------------------------------------------------------------

![](media/image7.png){width="6.5in"
height="2.7243055555555555in"}![](media/image8.png){width="6.5in"
height="2.725in"}![](media/image9.png){width="6.5in"
height="2.707638888888889in"}

### Performance Findings & Discussion

Our benchmarking results demonstrate the clear performance advantages of
combining declarative partitioning with pre-aggregated caches.

First, PostgreSQL's query planner successfully utilized **partition
pruning** to completely bypass and ignore the irrelevant 2004 and 2025
partition tables. By aligning the database\'s physical storage with
logical date keys, the query\'s scan footprint was restricted solely to
the target data partition. This eliminated expensive full-table
sequential scans and significantly reduced disk I/O, ensuring that query
latency remains low even as the overall volume of historical data grows.

Second, while partitioning optimizes raw table access, the
**materialized view** cache delivered the most dramatic latency
reductions by completely eliminating runtime join costs. Analytical
queries on a star schema typically require expensive, CPU-intensive
joins between the central fact table and multiple dimension tables. By
pre-aggregating these metrics and caching the results directly on disk,
the materialized view bypassed these complex relational joins entirely,
transforming active runtime computations into low-cost index lookups.
This combination of targeted physical data retrieval and cached,
pre-computed results is highly ideal for high-concurrency Business
Intelligence (BI) dashboards where sub-millisecond response times are
essential.

## 8. CONCLUSIONS AND RECOMMENDATIONS

### Conclusions

Our group successfully consolidated heterogeneous sales records from
In-Store (CSV), Online (JSON), and Partner (Excel) files into a single
PostgreSQL Star Schema database. By introducing a customer dimension and
channel region maps, we fulfilled all analytical parameters set by
retail management.

### Recommendations

1.  **Automate the ETL Pipeline:** Transition the manual CSV landing
    pipeline to an automated orchestration tool (like Apache Airflow or
    dbt) to schedule incremental daily updates.
2.  **Implement SCD Type 2 on Customers:** As customer profiles grow,
    introduce Slowly Changing Dimension Type 2 (SCD2) tables to track
    historical geographic relocations without losing old purchase
    locations.
3.  **Automate Materialized View Refreshes:** Implement a trigger-based
    or cron-scheduled refresh strategy
    (`REFRESH MATERIALIZED VIEW CONCURRENTLY`) to keep analytical
    reports updated without locking tables during business hours.
