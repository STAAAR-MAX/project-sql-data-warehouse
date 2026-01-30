# Katalog Data untuk Gold Layer

## Overview
Gold layer adalah lapisan data yang sudah diolah ke dalam bentuk yang siap digunakan untuk keperluan analitik dan reporting bisnis,
Struktur datanya terdiri dari **tabel dimensi** dan **tabel fakta** yang digunakan untuk mengukur dan menganalisis performa bisnis.

---

### 1. **gold.dim_customers**
- **Tujuan:** Menyimpan informasi pelanggan yang sudah dilengkapi dengan data demografi dan data geografis.
- **Kolom:**

| Nama Kolom     | Tipe Data     | Deskripsi                                                                                        |
|------------------|---------------|------------------------------------------------------------------------------------------------------|
| customer_key     | INT           | Kunci pengganti (surrogate key) yang digunakan untuk mengidentifikasi setiap record pelanggan secara unik pada tabel dimensi. |
| customer_id      | INT           | Nomor identitas unik berbentuk angka yang diberikan kepada setiap pelanggan.                      |
| customer_number  | NVARCHAR(50)  | Kode pelanggan berupa kombinasi huruf dan angka yang digunakan untuk kebutuhan pelacakan dan referensi data. |
| first_name       | NVARCHAR(50)  | Nama depan pelanggan sebagaimana tercatat di dalam sistem.                                        |
| last_name        | NVARCHAR(50)  | Nama belakang atau nama keluarga pelanggan yang tersimpan pada sistem.                            |
| country          | NVARCHAR(50)  | Negara tempat tinggal atau domisili pelanggan, misalnya Australia atau Indonesia.                 |
| marital_status   | NVARCHAR(50)  | Status pernikahan pelanggan, contohnya Menikah atau Lajang.                                       |
| gender           | NVARCHAR(50)  | Jenis kelamin pelanggan, misalnya Laki-laki, Perempuan, atau tidak tersedia.                      |
| birthdate        | DATE          | Tanggal kelahiran pelanggan dengan format tahun-bulan-hari (YYYY-MM-DD).                          |
| create_date      | DATE          | Tanggal dan waktu saat data pelanggan pertama kali dibuat atau dimasukkan ke dalam sistem.        |

---

### 2. **gold.dim_product**
- **Tujuan:** Menyimpan informasi tentang produk yang sudah dilengkapi dengan atributnya.
- **Kolom:**

| Nama Kolom        | Tipe Data     | Deskripsi                                                                                            |
|---------------------|---------------|----------------------------------------------------------------------------------------------------------|
| product_key         | INT           | Kunci pengganti (surrogate key) yang secara unik membedakan setiap data produk pada tabel dimensi produk. |
| product_id          | INT           | Identitas unik produk yang digunakan di dalam sistem untuk keperluan pelacakan dan referensi internal. |
| product_number      | NVARCHAR(50)  | Kode produk berupa kombinasi huruf dan angka yang digunakan untuk identifikasi, pengelompokan, atau pengelolaan inventaris. |
| product_name        | NVARCHAR(50)  | Nama produk yang bersifat deskriptif, biasanya mencakup informasi tipe, warna, atau ukuran produk. |
| category_id         | NVARCHAR(50)  | Kode unik kategori produk yang digunakan untuk menghubungkan produk dengan klasifikasi tingkat atasnya. |
| category            | NVARCHAR(50)  | Kelompok atau klasifikasi utama produk, misalnya Sepeda atau Komponen, untuk mengelompokkan produk sejenis. |
| subcategory         | NVARCHAR(50)  | Klasifikasi produk yang lebih rinci di dalam suatu kategori, biasanya menunjukkan jenis produk yang lebih spesifik. |
| maintenance_required| NVARCHAR(50)  | Menunjukkan apakah produk memerlukan perawatan berkala, misalnya Ya atau Tidak. |
| cost                | INT           | Nilai biaya atau harga dasar produk yang dinyatakan dalam satuan mata uang tertentu. |
| product_line        | NVARCHAR(50)  | Lini atau seri produk tempat produk tersebut berada, contohnya Road atau Mountain. |
| start_date          | DATE          | Tanggal mulai produk tersedia untuk dijual atau digunakan dalam operasional bisnis. |

--- 

### 3. **gold.fact_sales**
- **Tujuan:** Menyimpan informasi tentang data transaksi penjualan untuk tujuan analitik.
- **Kolom:**

| Nama Kolom     | Tipe Data    | Deskripsi                                                                                         |
|-----------------|---------------|----------------------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Kode unik berupa kombinasi huruf dan angka yang digunakan untuk mengidentifikasi setiap transaksi pesanan penjualan. |
| product_key     | INT           | Kunci pengganti yang menghubungkan data pesanan dengan tabel dimensi produk. |
| customer_key    | INT           | Kunci pengganti yang menghubungkan data pesanan dengan tabel dimensi pelanggan. |
| order_date      | DATE          | Tanggal saat pesanan dibuat atau dicatat oleh sistem. |
| shipping_date   | DATE          | Tanggal ketika pesanan dikirim kepada pelanggan. |
| due_date        | DATE          | Tanggal batas akhir pembayaran yang harus dipenuhi pelanggan untuk pesanan tersebut. |
| sales_amount    | INT           | Total nilai penjualan untuk item pesanan dalam satuan mata uang tanpa pecahan. |
| quantity        | INT           | Jumlah unit produk yang dipesan dalam satu baris transaksi. |
| price           | INT           | Harga per unit produk pada baris transaksi, dinyatakan dalam satuan mata uang tanpa p

