/*
===============================================================================
Eksplorasi Rentang Tanggal Data
===============================================================================
Tujuan:
    - Menentukan batas waktu awal dan akhir dari data utama.
    - Memahami cakupan periode data historis yang tersedia.

Fungsi SQL yang Digunakan:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- temukan tanggal pemesanan pertama dan terakhir
SELECT 
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date,
  DATEDIFF(year, MIN(order_date),MAX(order_date)) order_range_year
FROM gold.fact_sales

-- temukan tanggal pelanggan termuda dan tertua
SELECT
  MIN(birthdate) AS oldest_customer,
  DATEDIFF(year,MIN(birthdate),GETDATE()) AS oldets_age, --Ingin melihat usia
  MAX(birthdate) AS youngest_customer,
  DATEDIFF(year,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers
