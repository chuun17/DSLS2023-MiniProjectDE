--1. Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997.
SELECT DATENAME(MM, o.OrderDate) AS Bulan , COUNT(DISTINCT c.CustomerID) AS [Jumlah Customer]
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY DATENAME(MM, o.OrderDate)


--2. Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative.
SELECT FirstName + ' ' + LastName AS Nama, Title
FROM Employees
WHERE Title = 'Sales Representative'

--3. Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997.
SELECT TOP 5 p.ProductName, SUM(od.Quantity) AS [Jumlah Quantity]
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE DATENAME(MM, o.OrderDate) = 'January' AND YEAR(o.OrderDate) = 1997
GROUP BY p.ProductName
ORDER BY [Jumlah Quantity] DESC

--4. Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997.
SELECT c.CompanyName, p.ProductName, o.OrderDate
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE p.ProductName = 'Chai'
	AND DATENAME(MM, o.OrderDate) = 'June' 
	AND YEAR(o.OrderDate) = 1997

--5. Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
SELECT Pembelian, COUNT(Pembelian) AS [Jumlah Pembelian]
FROM (SELECT 
		CASE
			WHEN SUM(od.UnitPrice * od.Quantity) <= 100 THEN '<=100'
			WHEN SUM(od.UnitPrice * od.Quantity) <= 250 THEN '100<x<=250'
			WHEN SUM(od.UnitPrice * od.Quantity) <= 500 THEN '250<x<=500'
			ELSE '>500'
		END AS Pembelian
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	GROUP BY od.OrderID) a
GROUP BY Pembelian

--6. Tulis query untuk mendapatkan Company name pada tabel customer yang melakukan pembelian di atas 500 pada tahun 1997.
SELECT CompanyName, Pembelian
FROM (SELECT c.CompanyName, SUM(od.UnitPrice * od.Quantity) AS Pembelian
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	JOIN Customers c ON o.CustomerID = c.CustomerID
	WHERE YEAR(o.OrderDate) = 1997
	GROUP BY c.CompanyName) a
WHERE Pembelian > 500

--7. Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997. Sales itu hasil penjualan yg unit price kali quantity
SELECT a.ProductName, a.Bulan, a.Pembelian
FROM (SELECT p.ProductName, DATENAME(MM, o.OrderDate) AS Bulan, SUM(od.UnitPrice * od.Quantity) AS Pembelian, 
	RANK() OVER(PARTITION BY DATENAME(MM, o.OrderDate) ORDER BY SUM(od.UnitPrice * od.Quantity) DESC) AS RankPembelianMonthly
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	JOIN Products p ON od.ProductID = p.ProductID
	WHERE YEAR(o.OrderDate) = 1997
	GROUP BY DATENAME(MM, o.OrderDate), p.ProductName) a
WHERE RankPembelianMonthly <= 5
ORDER BY Bulan, RankPembelianMonthly

--8. Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga Setelah Discount.
CREATE VIEW ViewOrderDetails
AS
SELECT od.OrderID, od.ProductID, p.ProductName, od.UnitPrice, od.Quantity, od.Discount, 
	(od.UnitPrice * od.Quantity * (1-od.Discount)) AS [Harga setelah diskon]
FROM [Order Details] od
JOIN Products p ON od.ProductID = p.ProductID

SELECT * From ViewOrderDetails

--9. Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName/company name, OrderID, OrderDate, RequiredDate, 
--   ShippedDate jika terdapat inputan CustomerID tertentu.
CREATE PROCEDURE showInvoice 
	@IDCustomer NVARCHAR(5)
AS
SELECT c.CustomerID, COALESCE(c.CompanyName, c.ContactName) AS CustomerName, o.OrderID, o.OrderDate, o.RequiredDate, o.ShippedDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.CustomerID = @IDCustomer

exec showInvoice 'CACTU'
