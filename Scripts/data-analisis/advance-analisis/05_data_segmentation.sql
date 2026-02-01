/*
===============================================================================
5. Analisis Segmentasi Data (Data Segmentation Analysis)
===============================================================================
Tujuan:
    - Mengelompokkan data ke dalam kategori yang bermakna
      untuk menghasilkan insight yang lebih terarah.
    - Digunakan untuk segmentasi pelanggan, kategorisasi produk,
      atau analisis berdasarkan wilayah.

Fungsi SQL yang Digunakan:
    - CASE: Menentukan logika segmentasi kustom.
    - GROUP BY: Mengelompokkan data ke dalam segmen.

Rumusnya: [MEASURE] by [MEASURE] , Jadi harus memilih satu dari dua ukuran tersebut dimana satu ukutan itu
		  akan dirubah menjadi rentang, lalu menggabungkan data berdasarkan ukuran ini
Misalnya: Total product by sales range, total customers by age

===============================================================================

TASK: buatlah segmentasi produk ke dalam rentang biaya dan hitung berapa banyak produk yang termasuk dalam setiap segmen tersebut.
*/

SELECT
	cost_range,
	COUNT(product_cost) total_product
FROM (
SELECT
	product_name,
	product_cost,
CASE 
	WHEN product_cost < 100 THEN 'Below 100'
	WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE'Above 1000'
END cost_range
FROM gold.dim_product
)t
GROUP BY cost_range
ORDER BY total_product DESC
/* 
Kelompokkan pelanggan ke dalam tiga segmen berdasarkan perilaku pengeluaran mereka:
- VIP: riwayat minimal 12 bulan dan pengeluaran lebih dari €5.000.
- Reguler: riwayat minimal 12 bulan tetapi pengeluaran €5.000 atau kurang.
- Baru: masa aktif kurang dari 12 bulan.
Kemudian temukan jumlah total pelanggan untuk setiap kelompok.
*/
WITH CTE_summarize AS (
SELECT
	c.customer_key,
	MIN(f.order_date) early_order,
	MAX(f.order_date) end_order,
	DATEDIFF(month,MIN(f.order_date),MAX(f.order_date)) lifespan,
	SUM(f.sales_amount) total_spending
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
, CTE_criteria AS (
SELECT
	customer_key,
	lifespan,
	total_spending,
CASE 
	WHEN lifespan >=12 AND total_spending >5000 THEN 'VIP'
	WHEN lifespan >=12 AND total_spending <=5000 THEN 'Reguler'
	ELSE'New'
END customer_criteria
FROM CTE_summarize
)
SELECT
	customer_criteria,
	COUNT(customer_key) AS total_customers
FROM CTE_criteria
GROUP BY customer_cri
