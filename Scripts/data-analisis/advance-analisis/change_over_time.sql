/*
===============================================================================
1. Analisis Perubahan dari Waktu ke Waktu (Change Over Time Analysis)
===============================================================================
Tujuan:
    - Melacak tren, pertumbuhan, dan perubahan pada metrik utama dari waktu ke waktu.
    - Digunakan untuk analisis deret waktu (time-series) dan identifikasi pola musiman (seasonality).
    - Mengukur pertumbuhan atau penurunan kinerja pada periode tertentu.

Fungsi SQL yang Digunakan:
    - Fungsi Tanggal: DATEPART(), DATETRUNC(), FORMAT()
    - Fungsi Agregasi: SUM(), COUNT(), AVG()

Contohnya: total sales by year, average cost by month
===============================================================================
*/
-- Task: analisis performa sales dari waktu ke waktu*/
SELECT
	YEAR(order_date) order_year,
	COUNT(DISTINCT customer_key) tot_cus,
	SUM(quantity) tot_quan,
	SUM(sales_amount) tot_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY tot_sales DESC

-- by month
SELECT
	YEAR(order_date) order_year,
	MONTH(order_date) order_month,
	COUNT(DISTINCT customer_key) tot_cus,
	SUM(quantity) tot_quan,
	SUM(sales_amount) tot_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date), YEAR(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- DATETRUNC()
 SELECT
	DATETRUNC(month, order_date) order_date,
	COUNT(DISTINCT customer_key) tot_cus,
	SUM(quantity) tot_quan,
	SUM(sales_amount) tot_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

-- FORMAT()
 SELECT
	FORMAT(order_date,'yyyy-MM') order_date,
	COUNT(DISTINCT customer_key) tot_cus,
	SUM(quantity) tot_quan,
	SUM(sales_amount) tot_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MM')
ORDER BY FORMAT(order_date,'yyyy-MM')
