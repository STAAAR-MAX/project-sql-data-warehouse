/*
===============================================================================
Laporan Pelanggan (Customer Report)
===============================================================================
Tujuan:
    Laporan ini bertujuan untuk mengonsolidasikan metrik utama dan perilaku
    pelanggan berdasarkan data transaksi.

Highlight:
    1. Mengambil atribut penting pelanggan:
       - Nama pelanggan
       - Usia
       - Detail transaksi
    2. Melakukan segmentasi pelanggan berdasarkan:
       - Kategori pelanggan (VIP, Reguler, New)
       - Kelompok usia pelanggan
    3. Menghitung metrik agregasi pada level pelanggan:
       - Total jumlah pesanan
       - Total nilai penjualan
       - Total kuantitas pembelian
       - Total produk yang dibeli
       - Lama hubungan pelanggan (lifespan dalam bulan)
    4. Menghitung Key Performance Indicators (KPI):
       - Recency (bulan sejak transaksi terakhir)
       - Average Order Value
       - Average Monthly Spend
===============================================================================
*/
-- =============================================================================
-- Membuat Report: gold.report_customers
-- =============================================================================

-- =============================================================================
-- 1. Base Query
-- Mengambil kolom-kolom penting dari tabel fakta dan dimensi pelanggan
-- =============================================================================
IF OBJECT_ID ('gold.customers_report' ,'V') IS NOT NULL
DROP VIEW gold.customers_report;

GO

CREATE VIEW gold.customers_report AS
WITH CTE_base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.bithdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
),

-- =============================================================================
-- 2. Customer Aggregation
-- Menggabungkan dan meringkas metrik pada level pelanggan
-- =============================================================================
CTE_summarize AS (
    SELECT
        customer_key,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_product,
        MAX(order_date) AS end_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM CTE_base_query
    GROUP BY
        customer_key,
        customer_name,
        age
)

-- =============================================================================
-- 3. Final Customer Report
-- Menampilkan segmentasi pelanggan dan perhitungan KPI
-- =============================================================================
SELECT
    customer_key,
    customer_name,
    age,
    -- Segmentasi kelompok usia pelanggan
    CASE
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 40 THEN '30-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        WHEN age BETWEEN 51 AND 69 THEN '51-70'
        WHEN age > 70 THEN 'Above 70'
        ELSE 'n/a'
    END AS age_range,
    total_orders,
    total_sales,
    total_quantity,
    total_product,
    end_order_date,
    -- Menghitung Recency = Selisih bulan antara tanggal transaksi terakhir dan tanggal hari ini
    DATEDIFF(MONTH, end_order_date, GETDATE()) AS recency,
    lifespan,
    -- Segmentasi kategori pelanggan
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Reguler'
        ELSE 'New'
    END AS customer_criteria,
    -- Average Order Value (nilai pesanan rata-rata)
    -- Rumus: AOV = Total Sales / Total Orders
    -- Menggunakan CASE untuk menghindari pembagian dengan nol
    CASE
        WHEN total_sales = 0 THEN total_sales
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Average Monthly Spend (pengeluaran bulanan rata-rata)
    -- Rumus: Average Monthly Spend = Total Sales / Lifespan (bulan)
    -- Jika lifespan = 0 (pelanggan hanya bertransaksi dalam 1 bulan), maka nilai yang digunakan adalah total sales
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM CTE_summarize;
