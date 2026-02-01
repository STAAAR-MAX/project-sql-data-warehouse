===============================================================================
03. Performa Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Tujuan:
    - Mengukur kinerja produk, pelanggan, atau wilayah dari waktu ke waktu.
    - Digunakan untuk benchmarking serta mengidentifikasi entitas
      dengan performa tinggi.
    - Memantau tren dan pertumbuhan tahunan maupun bulanan.

Fungsi SQL yang Digunakan:
    - LAG(): Mengakses data pada baris sebelumnya.
    - AVG() OVER(): Menghitung nilai rata-rata dalam suatu partisi.
    - CASE: Menentukan logika kondisi untuk analisis tren.

Rumusnya: CURRENT[MEASURE]] - TARGET[MEASURE]
Misalnya: current sales - average sales
		  current year sales - previous year sales -- YOY analisis
		  current sales - lowest sales
===============================================================================

TASK: Analisis kinerja tahunan produk dengan membandingkan penjualan setiap produk dengan 
	kinerja penjualan rata-rata setiap produk dan penjualan tahun sebelumnya.
*/
WITH CTE_yearly_sum AS (
SELECT 
	YEAR(f.order_date) order_date,
	p.product_name,
	SUM(f.sales_amount) current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p. product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)
, CTE_category AS (
SELECT 
	order_date,
	product_name,
	current_sales,
	LAG (current_sales) OVER(PARTITION BY product_name ORDER BY order_date) prev_year,
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales
FROM CTE_yearly_sum
)

SELECT
	order_date,
	product_name,
	current_sales,
	prev_year,
	current_sales - prev_year AS yoy,
CASE 
	WHEN current_sales - prev_year > 0 THEN 'Increase'
	WHEN current_sales - prev_year < 0 THEN 'Decrease'
	ELSE 'No Change'
END yoy_category,
	avg_sales,
	current_sales - avg_sales AS diff_avg,
CASE
	WHEN current_sales - avg_sales > 0 THEN 'Above AVG'
	WHEN current_sales - avg_sales < 0 THEN 'Below AVG'
	ELSE 'AVG'
END avg_change
FROM CTE_category

-- TASK: Analisis performa tahunan customer dengan membandingkan total jumlah customer setiap negara dengan 
--	total jumlah customer tahun sebelumnya di setiap negara. YOY analisis dan Melihat akumulasi pertumbuhan customer dari waktu ke waktu
-- jgn tampilkan tahun 2022 karena baru berjalan 1 bulan
WITH CTE_yearly AS (
SELECT
	YEAR(order_date) order_year,
	c.country,
	COUNT(f.customer_key) total_nr_customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL AND country != 'n/a'
GROUP BY YEAR(order_date), c.country
)
, CTE_yoy AS (
SELECT
	order_year,
	country,
	total_nr_customer,
	LAG(total_nr_customer) OVER(PARTITION BY country ORDER BY order_year) py_total_nr_customer,
	total_nr_customer - LAG(total_nr_customer) OVER(PARTITION BY country ORDER BY order_year) yoy
FROM CTE_yearly
)

SELECT
	order_year,
	country,
	total_nr_customer,
	py_total_nr_customer,
	yoy,
	SUM(yoy) OVER(PARTITION BY country ORDER BY order_year) running_total,
CASE
	WHEN SUM(yoy) OVER(PARTITION BY country ORDER BY order_year) <= 500 THEN 'Low Growht'
	WHEN SUM(yoy) OVER(PARTITION BY country ORDER BY order_year) <= 1000 THEN 'Mid Growht'
	WHEN SUM(yoy) OVER(PARTITION BY country ORDER BY order_year) > 1000 THEN 'High Growht'
	ELSE'No Change'
END running_total_category
FROM CTE_yoy
WHERE order_year != '2022'
-- TASK: Analisis performa tahunan items subkategori produk dengan membandingkan total jumlah items setiap subkategori produk dengan 
--	kinerja total item rata-rata setiap subkategori produk yg terjual dan total items tahun sebelumnya dan tampilkan untuk 2013.
WITH CTE_yearlysum AS (
SELECT
	YEAR(f.order_date) AS order_year,
	p.subcategory,
	SUM(f.quantity) AS tot_quantity
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.subcategory
)
, CTE_analysis AS (
SELECT
	order_year,
	subcategory,
	tot_quantity,
	LAG(tot_quantity) OVER(PARTITION BY subcategory ORDER BY order_year) AS py_tot_quantity,
	AVG(tot_quantity) OVER(PARTITION BY subcategory) AS avg_tot_quantity
FROM CTE_yearlysum
)

SELECT
	order_year,
	subcategory,
	tot_quantity,
	py_tot_quantity,
	tot_quantity - py_tot_quantity AS yoy_tot_quantity,
CASE 
	WHEN (tot_quantity - py_tot_quantity) > 0 THEN 'Increase'
	WHEN (tot_quantity - py_tot_quantity)  < 0 THEN 'Decrease'
	ELSE 'No Change'
END yoy_category,
	avg_tot_quantity,
	tot_quantity - avg_tot_quantity AS diff_avg,
CASE 
	WHEN (tot_quantity - avg_tot_quantity) > 0 THEN 'Above AVG'
	WHEN (tot_quantity - avg_tot_quantity) < 0 THEN 'Below AVG'
	ELSE 'AVG'
END avg_change
FROM CTE_analysis
WHERE order_year = '2021'
