/*
Create Database and Schemas

Tujuan Script:
Script ini digunakan untuk membuat database baru bernama 'DataWarehouse'
dengan terlebih dahulu melakukan pengecekan apakah database tersebut sudah ada.
Jika database sudah ada, maka database akan dihapus dan dibuat ulang.
Selain itu, script ini juga membuat tiga schema di dalam database, yaitu:
- bronze : untuk menyimpan data mentah (raw data)
- silver : untuk menyimpan data yang telah dibersihkan dan distandarisasi
- gold   : untuk menyimpan data siap analisis dan reporting

PERINGATAN:
Menjalankan script ini akan menghapus seluruh database 'DataWarehouse'
jika database tersebut sudah ada. Semua data di dalam database akan
dihapus secara permanen. Pastikan Anda telah melakukan backup data
sebelum menjalankan script ini.
*/

USE master;
GO

-- Hapus dan buat ulang 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END
GO

--Buat Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;

-- Buat Schemas bronze, silver, gold
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

