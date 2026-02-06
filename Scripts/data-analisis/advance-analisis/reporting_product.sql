/*
===============================================================================
Laporan Produk (Product Report)
===============================================================================
Tujuan:
    Laporan ini bertujuan untuk mengonsolidasikan metrik utama dan perilaku produk
    berdasarkan data transaksi penjualan.
Highlight:
    1. Mengambil atribut penting produk, meliputi:
       - Nama produk
       - Kategori
       - Subkategori
       - Biaya produk (cost)

    2. Melakukan segmentasi produk berdasarkan pendapatan (revenue) untuk
       mengidentifikasi:
       - Produk dengan performa tinggi (High Performance)
       - Produk dengan performa menengah (Mid Range)
       - Produk dengan performa rendah (Low Performance)

    3. Menghitung metrik agregasi pada level produk:
       - Total jumlah pesanan
       - Total nilai penjualan
       - Total kuantitas produk terjual
       - Total pelanggan unik
       - Lama siklus penjualan produk (lifespan dalam bulan)
       - Rata-rata harga jual (avg_selling_price)

    4. Menghitung Key Performance Indicators (KPI):
       - Recency (jumlah bulan sejak penjualan terakhir)
       - Average Order Revenue (AOR)
       - Average Monthly Revenue
===============================================================================
*/
-- =============================================================================
-- Membuat Report: gold.report_products
-- =============================================================================

-- =============================================================================
-- 1. Base Query
-- Mengambil kolom-kolom penting dari tabel fakta penjualan dan dimensi produk
-- =============================================================================
IF OBJECT_ID ('gold.product_report', 'V') IS NOT NULL
DROP VIEW gold.product_report;
GO

CREATE VIEW gold.product_report AS 
WITH CTE_base_query AS (
    SELECT
        f.order_number,
        p.product_key,
        f.customer_key,
        f.order_date,
        f.quantity,
        f.sales_amount,
        p.product_name,
        p.subcategory,
        p.category,
        p.product_cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_product p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),
-- =============================================================================
-- 2. Product Aggregation
-- Menggabungkan dan meringkas metrik pada level produk
-- =============================================================================
CTE_summarize AS (
    SELECT
        product_key,
        product_name,
        subcategory,
        category,
        product_cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / COALESCE(quantity, 0)), 2) AS avg_selling_price
    FROM CTE_base_query
    GROUP BY
        product_key,
        product_name,
        subcategory,
        category,
        product_cost
)
-- =============================================================================
-- 3. Final Product Report
-- Menampilkan segmentasi produk dan perhitungan KPI
-- =============================================================================
SELECT
    product_key,
    product_name,
    subcategory,
    category,
    product_cost,
    total_customers,
    last_order_date,
    -- Recency (bulan sejak transaksi terakhir)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_month,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    -- Rumus: AOR = Total Sales / Total Orders
    -- Menggunakan CASE untuk menghindari pembagian dengan nol
    CASE
        WHEN total_sales = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    -- Rumus: Average Monthly Revenue = Total Sales / Lifespan (bulan)
    -- Jika lifespan = 0 (produk hanya terjual pada 1 bulan),
    -- maka nilai yang digunakan adalah total sales
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue,
    -- Segmentasi performa produk berdasarkan total penjualan
    CASE
        WHEN total_sales > 50000 THEN 'High Performance'
        WHEN total_sales > 10000 THEN 'Mid Range'
        ELSE 'Low Performance'
    END AS product_segment
FROM CTE_summarize;
