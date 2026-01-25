-- Tujuan script:
-- Script ini digunakan untuk membuat tabel-tabel pada schema bronze di Data Warehouse.
-- Setiap tabel akan dihapus terlebih dahulu jika sudah ada, kemudian dibuat kembali.
-- Script ini dijalankan untuk mendefinisikan ulang struktur tabel pada bronze layer
-- sebagai tempat penyimpanan data mentah (raw data) dari sistem sumber.
-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV CRM (cust_info)
===========================================================================================================  
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(50),
	cst_lastname		NVARCHAR(50),
	cst_marital_status	NVARCHAR(50),
	cst_gndr			NVARCHAR(50),
	cst_create_date		DATE
);

-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV CRM (prd_info)
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id			INT,
	prd_key			NVARCHAR(50),
	prd_nm			NVARCHAR(50),
	prd_cost		INT,
	prd_line		NVARCHAR(50),
	prd_start_dt	DATETIME,
	prd_end_dt		DATETIME
);

-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV CRM (sales_details)
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num		NVARCHAR(50),
	sls_prd_key		NVARCHAR(50),
	sls_cust_id		INT,
	sls_order_dt	INT,
	sls_ship_dt		INT,
	sls_due_dt		INT,
	sls_sales		INT,
	sls_quantity	INT,
	sls_price		INT
);

-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV ERP (CUST_AZ12)
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid		NVARCHAR(50),
	bdate	DATE,
	gen		NVARCHAR(50)
);

-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV ERP (LOC_AZ12)
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid		NVARCHAR(50),
	cntry	NVARCHAR(50)
);

-- Membuat tabel pada database Data Warehouse di layer bronze
-- yang bersumber dari file CSV ERP (PX_CAT_G1V2)
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id			NVARCHAR(50),
	cat			NVARCHAR(50),
	subcat		NVARCHAR(50),
	maintenance NVARCHAR(50)
);


