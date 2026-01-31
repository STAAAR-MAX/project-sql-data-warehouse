/*
===============================================================================
Eksplorasi Measures (Metrik Utama)
===============================================================================
Tujuan:
    - Menghitung metrik agregat (misalnya total dan rata-rata) untuk
      memperoleh gambaran cepat terhadap data.
    - Mengidentifikasi tren umum maupun kemungkinan anomali pada data.

Fungsi SQL yang Digunakan:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Level aggregasi tertingg | Level detail terendah
-- Task:
-- Temukan total penjualan
SELECT 
	SUM(sales_amount) Total_sales
FROM gold.fact_sales

-- Temukan berapa banyak item yg terjual
SELECT
	SUM(quantity) Total_quantity
FROM gold.fact_sales

-- Temukan harga rata-rata
SELECT
	AVG(price) avg_price
FROM gold.fact_sales

-- Temukan jumlah total order
SELECT
	COUNT(DISTINCT order_number) total_orders
FROM gold.fact_sales

-- temukan jumlah total produk
SELECT
	COUNT(product_key) Total_product
FROM gold.dim_product

-- temukan jumlah total customer
SELECT
	COUNT(customer_key) Total_customers
FROM gold.dim_customers

-- temukan jumlah total customer yg telah melakukan orders
SELECT
	COUNT(DISTINCT customer_key) total_customer_orders
FROM gold.fact_sales

-- Hasilkan laporan yg menunjukan semua kunci matrik bisnis
SELECT 'total_sales' AS measure ,SUM(sales_amount) AS value_measure FROM gold.fact_sales
UNION ALL
SELECT 'total_quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'avg_price', AVG(price) FROM gold.fact_sales
UNION ALL 
SELECT 'total_orders',COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total_product', COUNT(product_key) FROM gold.dim_product
UNION ALL
SELECT 'Total_customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'total_customer_orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales
