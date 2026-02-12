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

1️⃣ Segment Dağılımı
RFM modeline göre müşteri dağılımı aşağıdaki gibidir:
Segment	Müşteri Sayısı
Orta -> Seviye	41
Riskli -> 21
VIP	-> 16
Sadık ->	11
Müşterilerin büyük bir kısmı Orta Seviye segmentindedir.
VIP müşteriler toplam müşteri kitlesinin daha küçük bir bölümünü oluşturmaktadır.
Riskli segment dikkat çekici büyüklüktedir ve potansiyel geri kazanım stratejileri gerektirebilir.

2️⃣ Segment Bazlı Toplam Ciro Analizi
Segmentlerin toplam ciro katkısı aşağıdaki gibidir:
Segment	Toplam Ciro
VIP ->	574,111
Orta Seviye ->	507,523
Sadık -> 134,831
Riskli	-> 49,328
VIP segmenti en yüksek gelir katkısını sağlamaktadır.
Orta Seviye segment de ciddi bir gelir üretmektedir.
Riskli segmentin gelir katkısı oldukça düşüktür.

3️⃣ VIP Müşterilerin Toplam Gelir İçindeki Payı
VIP müşterilerin toplam gelir içindeki payı:
%45.36
VIP segmenti toplam gelirin yaklaşık %45’ini üretmektedir.
Gelir önemli ölçüde VIP müşterilerden gelmektedir, ancak şirket tamamen bu segmente bağımlı değildir.
Gelir dağılımı dengeli bir yapı göstermektedir.

🎯 Genel Değerlendirme
Bu analiz;
Az sayıda müşteri yüksek gelir üretmektedir.
VIP müşteriler korunmalı ve elde tutulmalıdır.
Riskli segment için yeniden kazanım stratejileri geliştirilebilir.
Orta Seviye segment büyütme potansiyeline sahiptir.
