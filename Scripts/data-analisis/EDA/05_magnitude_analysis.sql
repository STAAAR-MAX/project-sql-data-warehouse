/*
===============================================================================
Analisis Magnitudo Data
===============================================================================
Tujuan:
    - Mengukur besaran data serta mengelompokkan hasil berdasarkan dimensi tertentu.
    - Memahami distribusi data pada berbagai kategori yang tersedia.

Fungsi SQL yang Digunakan:
    - Fungsi Agregasi: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
    - LEFT JOIN
===============================================================================
*/
-- Temukan total pelanggan berdasarkan negara
SELECT
	country,
	COUNT(customer_key) Total_customersby_country
FROM gold.dim_customers
GROUP BY country
ORDER BY Total_customersby_country DESC

-- Temukan total pelanggan berdasarkan gender
SELECT
	gender,
	COUNT(customer_key) Total_customersby_gender
FROM gold.dim_customers
GROUP BY gender
ORDER BY Total_customersby_gender DESC

-- Temukan total produk berdasarkan kategori
SELECT
	category,
	COUNT(product_key) Tot_productby_cat
FROM gold.dim_product
GROUP BY category
ORDER BY Tot_productby_cat DESC

-- berapa rata-rata biaya diseteiap kategori
SELECT
	category,
	AVG(product_cost) avg_cost_product
FROM gold.dim_product
GROUP BY category
ORDER BY avg_cost_product DESC

-- berapa total revenue yg dihasilan dari setiap kategory
SELECT
	p.category,
	SUM(f.sales_amount) total_revenueby_category
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenueby_category DESC

-- berapa total revenu yg dihasilkan berdasarkan tiap customers
SELECT
	c.customer_key,
	c.first_name,
	SUM(f.sales_amount) total_revenueby_customers
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,c.first_name
ORDER BY total_revenueby_customers DESC

--bagaimana distribus barang yg terjual diberbagai negara
SELECT
	c.country,
	SUM(quantity) Total_sold_item_by_country
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY Total_sold_item_by_country DESC
