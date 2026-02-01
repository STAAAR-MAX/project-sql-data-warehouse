
/*
===============================================================================
4. Analisis Bagian terhadap Keseluruhan (Part-to-Whole Analysis)
===============================================================================
Tujuan:
    - Membandingkan kinerja atau metrik antar dimensi
      maupun antar periode waktu.
    - Mengevaluasi perbedaan kontribusi antar kategori.
    - Berguna untuk analisis A/B testing atau perbandingan wilayah.

Fungsi SQL yang Digunakan:
    - SUM(), AVG(): Menghitung nilai agregasi untuk keperluan perbandingan.
    - Fungsi Window: SUM() OVER() untuk perhitungan total keseluruhan.

Rumus: ([MEASURE]/TOTAL MEASURE])* 100 BY [DIMENSI]
Contohnya (sales/total sales)*100% by category
		  (quantity/total quantity)*100 by country
===============================================================================
TASK: kategori mana yg paling banyak berkontribusi pd seluruh penjualan
	*/
WITH CTE_sumbyproduct AS (
SELECT
	p.category,
	SUM(f.sales_amount) AS total_sales_by_category
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p.product_key
GROUP BY p.category
)
SELECT
	category,
	total_sales_by_category,
	SUM(total_sales_by_category) OVER () total_sales,
	CONCAT(ROUND((CAST(total_sales_by_category AS FLOAT) /SUM(total_sales_by_category) OVER ())*100,2), '%') percentage_of_total
FROM CTE_sumbyproduct

-- TASK: Negara mana yg paling banyak berkontribusi pd seluruh penjualan
WITH CTE_sumbycountry AS (
SELECT
	c.country,
	SUM(f.sales_amount) AS tot_salesby_country
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE c.country NOT LIKE 'n/a'
GROUP BY c.country
)
SELECT
	country,
	tot_salesby_country,
	SUM(tot_salesby_country) OVER() tot_sales,
	CONCAT(ROUND((CAST(tot_salesby_country AS FLOAT)/SUM(tot_salesby_country) OVER())*100,2),'%') AS percentage_of_total
FROM CTE_sumbycountry
ORDER BY tot_salesby_country DESC
