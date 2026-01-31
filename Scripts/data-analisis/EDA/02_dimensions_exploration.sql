/*
===============================================================================
Eksplorasi Tabel Dimensi
===============================================================================
Tujuan:
    - Meninjau struktur serta isi tabel-tabel dimensi dalam database.

Fungsi SQL yang Digunakan:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Task: eksplore semua negara asal pelanggan kami
SELECT DISTINCT 
  country
FROM gold.dim_customers
-- Task: eksplore semua kategori product 'divisi utama'
SELECT DISTINCT 
  category,
  subcategory, 
  product_name
FROM gold.dim_product
ORDER BY 1,2,3
