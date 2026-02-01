/*
===============================================================================
2. Analisis Kumulatif (Cumulative Analysis)
===============================================================================
Tujuan:
    - Menghitung total berjalan (running total) atau rata-rata bergerak
      untuk metrik utama.
    - Memantau kinerja secara kumulatif dari waktu ke waktu.
    - Berguna untuk analisis pertumbuhan dan identifikasi tren jangka panjang.

Rumus: gabungan cumulatif measeure by dimensi tanggal
misalnya running total sales by year, moving average of sales by month

Fungsi SQL yang Digunakan:
    - Fungsi Window: SUM() OVER(), AVG() OVER()
===============================================================================

TASK: hitung total sales per bulan dan running total of sales waktu ke waktu */
SELECT 
	order_month,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_month) running_total
FROM
(SELECT
	DATETRUNC(month, order_date) order_month,
	SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t

-- TASK: hitung total sales per tahun dan running total of sales waktu ke waktu
SELECT 
	order_year,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_year) running_total
FROM
(SELECT
	DATETRUNC(year, order_date) order_year,
	SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t
