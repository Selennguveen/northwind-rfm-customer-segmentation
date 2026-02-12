📌 Northwind RFM Customer Segmentation
🔎 Project Overview
Bu projede Northwind veri seti kullanılarak RFM (Recency, Frequency, Monetary) modeli ile müşteri segmentasyonu gerçekleştirilmiştir. Amaç, müşterileri davranışsal olarak sınıflandırmak ve segment bazlı gelir analizini yapmaktır.

📊 RFM Modeli
Recency (R): Müşterinin son siparişinden bu yana geçen gün sayısı
Frequency (F): Toplam sipariş sayısı
Monetary (M): Toplam harcama tutarı
Müşteriler her metrikte 1–5 arasında puanlanmış ve toplam RFM skoruna göre segmentlere ayrılmıştır.

🎯 Segment Tanımları
VIP: Yüksek harcama, yüksek sipariş sıklığı ve güncel müşteri
Sadık: Aktif ve düzenli alışveriş yapan müşteri
Riskli: Uzun süredir alışveriş yapmayan ve düşük harcama yapan müşteri
Orta Seviye: Diğer segmentlere girmeyen müşteriler

📈 Analiz Sonuçları
VIP müşteriler toplam gelirin yaklaşık %45’ini oluşturmaktadır.
Gelir dağılımı segmentler arasında dengeli bir yapı göstermektedir.
Az sayıda müşteri yüksek gelir üretmektedir ancak gelir tamamen tek bir segmente bağımlı değildir.

🛠 Kullanılan SQL Teknikleri
JOIN
GROUP BY
CTE (Common Table Expression)
Window Functions (NTILE)
CASE ile segment üretimi
Agregasyon (SUM, COUNT)