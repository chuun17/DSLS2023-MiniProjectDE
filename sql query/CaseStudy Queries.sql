-- Product Analysis -> trend berdasarkan totalRevenue dan totalTransaksi untuk setiap kategori produk
SELECT a.Month, c.CategoryName, SUM(a.Sales) AS TotalRevenue, COUNT(a.Sales) AS TotalTransaction
FROM
(SELECT od.ProductID, (od.UnitPrice * od.Quantity * (1-od.Discount)) AS Sales,
	CONVERT(NVARCHAR(4), YEAR(o.OrderDate)) + '-' + DATENAME(MM, o.OrderDate) AS Month
FROM [Order Details] od
JOIN Orders o ON od.OrderID = o.OrderID) a
JOIN Products p ON a.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY a.Month, c.CategoryName
ORDER BY a.Month, c.CategoryName


-- Customer Analysis -> RFM Analysis pada tahun 1997
SELECT o.CustomerID,
	MIN(DATEDIFF(DAY, '1997-12-31', o.OrderDate) * (-1)) AS Recency, 
	COUNT(o.OrderID) AS Frequency, 
	SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS Monetary
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY o.CustomerID

-- Supplier Analysis -> Supplier yang paling banyak menghasilkan cuan
SELECT s.CompanyName, 
	SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS Revenue
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY s.CompanyName
ORDER BY Revenue DESC
