-- ==============================================================================
-- Stored Procedure: Load Silver Layer (Bronze → Silver)
-- ==============================================================================

-- Tujuan Script:
-- Stored procedure ini digunakan untuk menjalankan proses ETL
-- (Extract, Transform, Load) dari schema bronze ke schema silver.
--
-- Proses ini bertujuan untuk memuat data yang telah dibersihkan,
-- distandarisasi, dan divalidasi dari layer bronze ke layer silver
-- sebagai bagian dari arsitektur Data Warehouse (Bronze–Silver–Gold).
--
-- Tindakan yang Dilakukan:
-- 1. Mengosongkan (TRUNCATE) seluruh tabel pada schema silver.
-- 2. Memasukkan (INSERT) data hasil transformasi dan cleansing
--    dari tabel-tabel pada schema bronze ke schema silver.
-- 3. Melakukan standarisasi nilai, normalisasi data, dan
--    penanganan data anomali sesuai aturan bisnis.
--
-- Parameter:
-- - Tidak menerima parameter input.
-- - Tidak mengembalikan nilai output.
--
-- Contoh Penggunaan:
-- EXEC silver.load_silver;
--
-- ==============================================================================

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT '=================================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================================================================';

		PRINT '---------------------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Table: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
		CASE
			WHEN TRIM(UPPER(cst_marital_status)) LIKE 'M' THEN 'Married'
			WHEN TRIM(UPPER(cst_marital_status)) LIKE 'S' THEN 'Single'
			ELSE 'n/a'
		END cst_marital_status,
		CASE
			WHEN TRIM(UPPER(cst_gndr)) LIKE 'M' THEN 'Male'
			WHEN TRIM(UPPER(cst_gndr)) LIKE 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gndr,
			cst_create_date
		FROM (
		SELECT*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Table: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,  --extra colom category id
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,		--extra colom produk key
			RTRIM(prd_nm, '.') AS prd_nm,
			COALESCE(prd_cost, 0) prd_cost,
		CASE TRIM(UPPER(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'										 -- membuat deskripsi kode untuk prd line
		END prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key 
			ORDER BY prd_start_dt ASC)-1 AS DATE) AS prd_end_dt  -- menghitung dgn cara mengurangi satu hari terakhir sebelum hari berikutnya dimulai
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Table: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
		CASE
			WHEN sls_order_dt < 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)						-- Pertama kita rubah data yg negatif atau 0 atau panjang string kurang 8 karena akan diconvert menjadi DATE,
		END sls_order_dt,														--tapi kita harus merubah dulu menjadi varchar karena slq server tidak bisa langsung merubah dari INT	
			CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE) AS sls_ship_dt,			--hal sama dilakukan di sini karena aman langsung rubah aja
			CAST(CAST(sls_due_dt AS VARCHAR)AS DATE) AS sls_due_dt,				--hal sama dilakukan di sini karena aman langsung rubah aja
		CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) 
				THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
			sls_quantity,
		CASE WHEN sls_price <=0 OR sls_price IS NULL 
				THEN sls_sales/ NULLIF(sls_quantity,0)
			ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';

		PRINT '---------------------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Table: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
		CASE
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) -- Menghapus awalan 'NAS' jika ada karena akan digunakan untuk kunci join ke customer
			ELSE cid
		END AS cid,
		CASE
			WHEN bdate < '1935-01-01' OR bdate > GETDATE() THEN NULL -- Mengatur anomali tgl lahir yg terlalu lama dan yg akan datang
			ELSE bdate
		END AS bdate,
		CASE
			WHEN UPPER(TRIM(gen)) IN('F','Female') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male' -- Menormalisasi data gen agar mudah dibaca dan menghapus nilai NULL
			ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Table: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid,'-','') cid, -- Mengganti nilai pd string
		CASE
			WHEN TRIM(cntry) IN('USA', 'US') THEN 'United States'
			WHEN TRIM(cntry) LIKE 'DE' THEN 'Germany'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry) -- Menormalisasi data dan menangani nilai null atau kolom kosong
		END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v21';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '>> -Total Load Duration ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' second';
		PRINT '>> --------------------------------------------------------------------------------';
	END TRY
	BEGIN CATCH
		PRINT '========================================';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '========================================';
	END CATCH 
END 

