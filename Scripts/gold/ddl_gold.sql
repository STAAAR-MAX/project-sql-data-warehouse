/* ============================================================
   DDL Script: Create Gold Views
   ============================================================

   Tujuan Script:
   Script ini digunakan untuk membuat view pada layer Gold di
   data warehouse. Layer Gold merupakan lapisan data akhir yang
   telah disusun dalam bentuk tabel dimensi dan tabel fakta
   (Star Schema) sehingga siap digunakan untuk kebutuhan bisnis.

   Setiap view melakukan proses transformasi serta penggabungan
   data dari layer Silver untuk menghasilkan data yang lebih bersih,
   terstruktur, dan siap digunakan untuk analitik serta pelaporan.

   Penggunaan:
   View yang dihasilkan dapat langsung digunakan oleh tim analitik,
   BI tools, maupun kebutuhan reporting bisnis tanpa perlu proses
   transformasi tambahan.

   ============================================================
*/


/* ============================================================
   View Creation: gold.dim_customers
   ------------------------------------------------------------
   Deskripsi:
   View ini membentuk tabel dimensi pelanggan pada layer Gold.
   Data pelanggan diambil dari sistem CRM lalu diperkaya dengan
   data tambahan dari sistem ERP seperti gender dan lokasi.
   Hasil akhirnya menjadi dataset pelanggan yang bersih dan siap
   digunakan untuk analisis bisnis.
   ============================================================ */

IF OBJECT_ID ('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	lo.cntry AS country,
	ci.cst_marital_status AS marital_status,		
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr		-- crm adalah master tabel
		ELSE ca.gen
	END AS gender,	
	ca.bdate AS bithdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 lo
ON		  ci.cst_key = lo.cid


/* ============================================================
   View Creation: gold.dim_product
   ------------------------------------------------------------
   Deskripsi:
   View ini membentuk tabel dimensi produk yang berisi informasi
   produk lengkap beserta kategori dan karakteristiknya.
   Data diambil dari CRM dan digabungkan dengan data kategori ERP,
   kemudian data historis yang sudah tidak aktif difilter sehingga
   hanya produk yang masih berlaku yang digunakan.
   ============================================================ */

IF OBJECT_ID ('gold.dim_product','V') IS NOT NULL
	DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
SELECT
	ROW_NUMBER() OVER(ORDER BY pin.prd_start_dt,pin.prd_key) AS product_key,
	pin.prd_id AS product_id,
	pin.cat_id AS categoty_id,
	pin.prd_key AS product_number,
	pin.prd_nm AS product_name,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	pin.prd_cost AS product_cost,
	pin.prd_line AS prdouct_line,
	pin.prd_start_dt AS product_start_date
FROM silver.crm_prd_info pin
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON		  pin.cat_id = pc. id   
WHERE pin.prd_end_dt IS NULL	-- Memfilter data history 


/* ============================================================
   View Creation: gold.fact_sales
   ------------------------------------------------------------
   Deskripsi:
   View ini membentuk tabel fakta penjualan pada layer Gold.
   Data transaksi penjualan dari layer Silver dihubungkan dengan
   tabel dimensi produk dan pelanggan untuk menghasilkan dataset
   transaksi yang siap dianalisis dalam skema bintang (Star Schema).
   ============================================================ */

IF OBJECT_ID ('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS 
SELECT
	sd.sls_ord_num AS order_number,
	p.product_key,
	c.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price,
	sd.sls_sales AS sales_amount
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product p
ON sd.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c
ON sd.sls_cust_id = c.customer_id
