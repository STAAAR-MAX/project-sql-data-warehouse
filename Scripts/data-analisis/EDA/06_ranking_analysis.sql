/*
===============================================================================
Analisis Peringkat (Ranking)
===============================================================================
Tujuan:
    - Memberikan peringkat pada item (misalnya produk atau pelanggan)
      berdasarkan kinerja atau metrik tertentu.
    - Mengidentifikasi entitas dengan performa terbaik maupun terendah.

Fungsi SQL yang Digunakan:
    - Fungsi Ranking Window: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Klausa: GROUP BY, ORDER BY
===============================================================================
*/

-- apa top 10 produk dgn performa penjualan terbaik
SELECT *
FROM (
SELECT
	p.product_key,
	p.product_name,
	SUM(f.sales_amount) total_sales_product,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount)DESC) rank_product
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key = p. product_key
GROUP BY p.product_key, p.product_name
)t
WHERE rank_product <=10

-- apa top 10 produk dgn performa penjualan terburuk
SELECT TOP 10
	p.product_key,
	p.product_name,
	SUM(f.sales_amount) total_sales_product
FROM gold.fact_sales f RANK
LEFT JOIN gold.dim_product p
ON f.product_key = p. product_key
GROUP BY p.product_key, p.product_name

-- Temukan 10 pelanggan teratas yg menghasilan revenue tertinggi dan 3 pelanggan dgn pesanan paling sedikit
SELECT*
FROM (
SELECT
	c.customer_key,
	c.first_name,
	SUM(f.sales_amount) total_revenueby_customers,
	ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount)DESC) rank_customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,c.first_name
)t
WHERE rank_customer <=10

--top 3 pelanggan dgn pesanan paling sediit
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT f.order_number) total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key,c.first_name, c.last_name
ORDER BY total_orders
