/*
===============================================================================
Pemeriksaan Kualitas Data (Quality Checks)
===============================================================================
Tujuan Script:
    Script ini digunakan untuk melakukan pemeriksaan kualitas data guna
    memastikan integritas, konsistensi, dan akurasi data pada layer Gold.
    Pemeriksaan ini mencakup:
    - Memastikan surrogate key pada tabel dimensi bersifat unik.
    - Memastikan integritas referensi antara tabel fakta dan tabel dimensi.
    - Memvalidasi hubungan antar tabel dalam model data untuk kebutuhan analitik.

Catatan Penggunaan:
    - Setiap ketidaksesuaian atau anomali data yang ditemukan selama proses
      pemeriksaan perlu dianalisis dan diperbaiki sebelum data digunakan
      untuk analitik atau pelaporan.
===============================================================================
*/

-- ====================================================================
-- Pemeriksaan tabel 'gold.dim_customers'
-- ====================================================================
-- Mengecek keunikan Customer Key pada tabel gold.dim_customers
-- Harapan hasil: Tidak ada data yang muncul
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Pemeriksaan tabel 'gold.product_key'
-- ====================================================================
-- Mengecek keunikan Product Key pada tabel gold.dim_products
-- Harapan hasil: Tidak ada data yang muncul
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Pemeriksaan tabel 'gold.fact_sales'
-- ====================================================================
-- Mengecek keterhubungan data antara tabel fakta dan tabel dimensi
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL

