-- =============================================
-- Project: Northwind RFM Customer Segmentation
-- Author: Selen
-- Description:
-- RFM modeli kullanılarak müşteri segmentasyonu
-- ve segment bazlı gelir analizi yapılmıştır.
-- =============================================


-- 1-Toplam Ciro Hesaplama (Monetary Analysis)
-- Her müşterinin indirimli gerçek satış tutarının hesaplanması
SELECT o.CustomerID, c.CompanyName,
SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as TotalRevenue
FROM [Order Details] od
JOIN Orders o on od.OrderID = o.OrderID
JOIN Customers c on c.CustomerID = o.CustomerID
GROUP BY o.CustomerID, c.CompanyName
ORDER BY TotalRevenue DESC


-- 2-Toplam Sipariş Sayısı Hesaplama (Frequency Analysis)
-- Her müşterinin verdiği toplam sipariş sayısının hesaplanması
SELECT c.CustomerID, c.CompanyName, COUNT(o.OrderID) as TotalOrders 
FROM Customers c
JOIN Orders o on c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY c.CustomerID 


-- 3-Son Sipariş Tarihi Analizi (Recency - Last Order Date)
-- Her müşterinin en son sipariş tarihinin bulunması
SELECT c.CustomerID, c.CompanyName,
MAX(o.OrderDate) as LastOrderDate
from Customers c
JOIN Orders o on o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName


-- 4-Veri Setindeki Maksimum Sipariş Tarihi
-- Recency hesaplamasında referans alınacak en güncel tarih
SELECT OrderDate from Orders
WHERE OrderDate = (SELECT MAX(OrderDate) from Orders)
GROUP BY OrderDate

-- 5-Recency Gün Farkı Hesaplama
-- Müşterinin son siparişinden bugüne kadar geçen gün sayısı
SELECT c.CustomerID, c.CompanyName, MAX(o.OrderDate) as LastOrderDate,
CASE
    WHEN MAX(o.OrderDate) IS NULL THEN NULL
    ELSE DATEDIFF(DAY, MAX(o.OrderDate), (SELECT MAX(OrderDate) FROM Orders))
END AS RecencyDays
FROM Customers c
JOIN Orders o on o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY RecencyDays ASC

-- 6-CustomerBase CTE: RFM Temel Metrik Tablosu
-- Monetary, Frequency ve Recency metriklerinin tek tabloda birleştirilmesi
WITH CustomerBase AS(
    SELECT c.CustomerID, c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as TotalRevenue,
        COUNT(o.OrderID) as TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), (SELECT MAX(OrderDate) FROM Orders)) as RecencyDays
    FROM Customers c
    JOIN Orders o on o.CustomerID = c.CustomerID
    JOIN [Order Details] od on o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
)   
SELECT *
FROM CustomerBase
ORDER BY TotalRevenue DESC

-- 7-RFM Skorlama (NTILE ile 1-5 Segment Üretimi)
-- Müşterilerin harcama, sipariş sıklığı ve recency değerlerine göre puanlanması
WITH CustomerBase AS(
    SELECT c.CustomerID, c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as TotalRevenue,
        COUNT(o.OrderID) as TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), (SELECT MAX(OrderDate) FROM Orders)) as RecencyDays
    FROM Customers c
    JOIN Orders o on o.CustomerID = c.CustomerID
    JOIN [Order Details] od on o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
) 
SELECT *,
    NTILE(5) OVER (ORDER BY TotalRevenue ASC) AS RevenueSegment,
    NTILE(5) OVER (ORDER BY TotalOrders ASC) AS OrderFrequencySegment,
    NTILE(5) OVER (ORDER BY RecencyDays DESC) AS RecencySegment
FROM CustomerBase

-- 8-RFM Segment Tanımlama (Business Rule Layer)
-- Toplam RFM skorunun hesaplanması ve müşteri segmentlerinin atanması
WITH CustomerBase AS(
    SELECT c.CustomerID, c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as TotalRevenue,
        COUNT(o.OrderID) as TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), (SELECT MAX(OrderDate) FROM Orders)) as RecencyDays
    FROM Customers c
    JOIN Orders o on o.CustomerID = c.CustomerID
    JOIN [Order Details] od on o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ScoredCustomers AS(
    SELECT *,
    NTILE(5) OVER (ORDER BY TotalRevenue ASC) AS RevenueSegment,
    NTILE(5) OVER (ORDER BY TotalOrders ASC) AS OrderFrequencySegment,
    NTILE(5) OVER (ORDER BY RecencyDays DESC) AS RecencySegment
FROM CustomerBase
),
SegmentCustomers AS(
    SELECT *,
    (RevenueSegment + OrderFrequencySegment + RecencySegment) AS TotalRFMScore,
    CASE
        WHEN RevenueSegment >= 4 
             AND OrderFrequencySegment >= 4 
             AND RecencySegment >= 4 
        THEN 'VIP'

        WHEN RecencySegment >= 4 
             AND OrderFrequencySegment >= 3 
        THEN 'Sadık'

        WHEN RecencySegment <= 2 
             AND RevenueSegment <= 2 
        THEN 'Riskli'

        ELSE 'Orta Seviye'
    END AS CustomerSegment
FROM ScoredCustomers
)
SELECT * FROM SegmentCustomers;

-- 9-Segment Bazlı Müşteri Dağılımı Analizi
-- Her segmentte kaç müşteri olduğunun hesaplanması
WITH CustomerBase AS(
    SELECT 
        c.CustomerID, 
        c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS TotalRevenue,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), 
                (SELECT MAX(OrderDate) FROM Orders)) AS RecencyDays
    FROM Customers c
    JOIN Orders o ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ScoredCustomers AS(
    SELECT *,
        NTILE(5) OVER (ORDER BY TotalRevenue ASC) AS RevenueSegment,
        NTILE(5) OVER (ORDER BY TotalOrders ASC) AS OrderFrequencySegment,
        NTILE(5) OVER (ORDER BY RecencyDays DESC) AS RecencySegment
    FROM CustomerBase
),
SegmentCustomers AS(
    SELECT *,
        (RevenueSegment + OrderFrequencySegment + RecencySegment) AS TotalRFMScore,
        CASE
            WHEN RevenueSegment >= 4 
                 AND OrderFrequencySegment >= 4 
                 AND RecencySegment >= 4 
            THEN 'VIP'

            WHEN RecencySegment >= 4 
                 AND OrderFrequencySegment >= 3 
            THEN 'Sadık'

            WHEN RecencySegment <= 2 
                 AND RevenueSegment <= 2 
            THEN 'Riskli'

            ELSE 'Orta Seviye'
        END AS CustomerSegment
    FROM ScoredCustomers
)

SELECT 
    CustomerSegment,
    COUNT(*) AS MusteriSayisi
FROM SegmentCustomers
GROUP BY CustomerSegment
ORDER BY MusteriSayisi DESC;

-- 10-Segment Bazlı Toplam Ciro Analizi
-- Hangi müşteri segmentinin daha fazla gelir ürettiğinin belirlenmesi
WITH CustomerBase AS(
    SELECT 
        c.CustomerID, 
        c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS TotalRevenue,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), 
                (SELECT MAX(OrderDate) FROM Orders)) AS RecencyDays
    FROM Customers c
    JOIN Orders o ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ScoredCustomers AS(
    SELECT *,
        NTILE(5) OVER (ORDER BY TotalRevenue ASC) AS RevenueSegment,
        NTILE(5) OVER (ORDER BY TotalOrders ASC) AS OrderFrequencySegment,
        NTILE(5) OVER (ORDER BY RecencyDays DESC) AS RecencySegment
    FROM CustomerBase
),
SegmentCustomers AS(
    SELECT *,
        (RevenueSegment + OrderFrequencySegment + RecencySegment) AS TotalRFMScore,
        CASE
            WHEN RevenueSegment >= 4 
                 AND OrderFrequencySegment >= 4 
                 AND RecencySegment >= 4 
            THEN 'VIP'

            WHEN RecencySegment >= 4 
                 AND OrderFrequencySegment >= 3 
            THEN 'Sadık'

            WHEN RecencySegment <= 2 
                 AND RevenueSegment <= 2 
            THEN 'Riskli'

            ELSE 'Orta Seviye'
        END AS CustomerSegment
    FROM ScoredCustomers
)

SELECT 
    CustomerSegment,
    SUM(TotalRevenue) AS SegmentCirosu
FROM SegmentCustomers
GROUP BY CustomerSegment
ORDER BY SegmentCirosu DESC;

-- 11-VIP Gelir Oranı Analizi
-- VIP müşterilerin toplam gelir içindeki yüzde payının hesaplanması
WITH CustomerBase AS(
    SELECT 
        c.CustomerID, 
        c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS TotalRevenue,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        DATEDIFF(DAY, MAX(o.OrderDate), 
                (SELECT MAX(OrderDate) FROM Orders)) AS RecencyDays
    FROM Customers c
    JOIN Orders o ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID, c.CompanyName
),
ScoredCustomers AS(
    SELECT *,
        NTILE(5) OVER (ORDER BY TotalRevenue ASC) AS RevenueSegment,
        NTILE(5) OVER (ORDER BY TotalOrders ASC) AS OrderFrequencySegment,
        NTILE(5) OVER (ORDER BY RecencyDays DESC) AS RecencySegment
    FROM CustomerBase
),
SegmentCustomers AS(
    SELECT *,
        (RevenueSegment + OrderFrequencySegment + RecencySegment) AS TotalRFMScore,
        CASE
            WHEN RevenueSegment >= 4 
                 AND OrderFrequencySegment >= 4 
                 AND RecencySegment >= 4 
            THEN 'VIP'

            WHEN RecencySegment >= 4 
                 AND OrderFrequencySegment >= 3 
            THEN 'Sadık'

            WHEN RecencySegment <= 2 
                 AND RevenueSegment <= 2 
            THEN 'Riskli'

            ELSE 'Orta Seviye'
        END AS CustomerSegment
    FROM ScoredCustomers
)

SELECT 
    SUM(CASE WHEN CustomerSegment = 'VIP' THEN TotalRevenue END) * 100.0
    / SUM(TotalRevenue) AS VIP_Ciro_Yuzdesi
FROM SegmentCustomers;















