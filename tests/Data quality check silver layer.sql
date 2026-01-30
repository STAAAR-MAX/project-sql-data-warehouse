-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Mengecek nilai NULL atau duplikat pada primary key
-- Ekspektasi: tidak ada masalah
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
   OR cst_id IS NULL;

-- Mengecek apakah ada spasi tidak perlu pada kolom string
-- Ekspektasi: tidak ada
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Standarisasi & normalisasi data
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Mengecek nilai NULL atau duplikat pada primary key
-- Ekspektasi: tidak ada masalah
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
   OR prd_id IS NULL;

-- Mengecek spasi tidak perlu atau karakter tidak diinginkan
-- Ekspektasi: tidak ada
SELECT
    prd_line
FROM silver.crm_prd_info
WHERE prd_line != TRIM(prd_line);

SELECT
    prd_line
FROM silver.crm_prd_info
WHERE prd_line LIKE '%.'
   OR prd_line LIKE '.%';

-- Mengecek nilai negatif atau NULL pada cost
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;

-- Standarisasi data (kode/singkatan → nilai deskriptif)
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

-- Mengecek tanggal invalid (start_date > end_date)
-- Seharusnya: start_date < end_date
SELECT *
FROM silver.crm_prd_info
WHERE prd_start > prd_end_date;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Mengecek spasi tidak perlu pada sales order number
SELECT
    sls_ord_num
FROM silver.crm_sales_datails
WHERE sls_ord_num != TRIM(sls_ord_nm);

-- CHECK INVALID DATE
-- Mencari nilai negatif, 0, atau format tanggal tidak valid
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_d > 20300101
   OR sls_order_d > 20000101;

-- Mengecek tanggal tidak valid
-- Order Date harus lebih awal dari Ship dan Due Date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt
   OR sls_ship_dt < sls_order_dt;

/*
Check pada kolom:
- sls_sales
- sls_quantity
- sls_price

Aturan bisnis:
sales = price * quantity
*/
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;

/*
ATURAN PERBAIKAN DATA:
- Jika sales negatif, 0, atau NULL → hitung dari quantity * price
- Jika price 0 atau NULL → hitung dari sales / quantity
- Jika price negatif → konversi ke positif
*/


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Ekstraksi customer ID agar konsisten
-- Cek anomali birth date
-- Ekspektasi: bdate antara '1935-01-01' dan hari ini
SELECT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1935-01-01'
   OR bdate > GETDATE();

-- Standarisasi & konsistensi data gender
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Standarisasi & konsistensi data negara
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Mengecek spasi tidak diinginkan
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM silver.erp_px_cat_g1v2
WHERE id != TRIM(id)
   OR cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Standarisasi & konsistensi data kategori
SELECT DISTINCT
    cat
FROM silver.erp_px_cat_g1v2;
