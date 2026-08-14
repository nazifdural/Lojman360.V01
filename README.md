# LOJMAN Yönetim Sistemi – FastAPI v09

Bu paket, başarıyla doğrulanan `LOJMANDB` veritabanının üzerine ilk web
uygulaması katmanını kurar.

## Bu sürümde bulunanlar

v01'den gelenler:

- FastAPI iskeleti, SQLAlchemy + aioodbc bağlantı havuzu
- Windows Kimlik Doğrulaması, ODBC Driver 18 / 17 otomatik seçimi
- Başlangıçta 12 tablo, 9 görünüm, 6 prosedür ve 14 tetikleyici kontrolü
- Her isteğin başında `SP_ISLEM_BAGLAMI_AYARLA`, sonunda
  `SP_ISLEM_BAGLAMI_TEMIZLE`
- İstek kimliği (`X-Request-ID`) üretimi ve `/api/sistem/durum`

v02 ile gelenler:

- İlk sistem yöneticisi oluşturma ekranı (yalnızca bir kez açılır)
- Kullanıcı girişi, çıkış ve zorunlu parola değiştirme
- Argon2id parola hash'leme; açık metin parola hiçbir yerde saklanmaz
- Parola kuralları: en az 12 karakter, en az bir harf ve bir rakam
- Beş hatalı denemede 15 dakika kilit (`SP_KULLANICI_GIRIS_BASARISIZ`)
- Kullanıcı adının varlığını sızdırmayan giriş hataları
- Formlarda CSRF belirteci
- Oturum sırasında hesap pasife alınırsa (`54021`) oturumun otomatik
  düşürülmesi
- Çıkış ve kullanıcının bulunamadığı başarısız girişler için
  `SP_ISLEM_LOG_EKLE`; veri değiştiren işlemleri tetikleyiciler loglar

v03 ile gelenler:

- Kullanıcı listesi, kullanıcı ekleme ve düzenleme
- Rol atama (tam küme mantığı) ve yönetici parola sıfırlama
- Hesap kilidini süre dolmadan açma
- `VW_KULLANICI_YETKILERI` üzerinden istek başına yetki denetimi
- Yetkiye göre gizlenen menü ve düğmeler

v04 ile gelenler:

- Lokasyon, oda ve yatak tanım ekranları (listeleme, ekleme, düzenleme, silme)
- Lokasyona göre oda, odaya göre yatak süzme
- `VW_ODA_KAPASITE` ve `VW_YATAK_LISTESI` üzerinden kapasite ve yatak kodu
- Kısıt ihlallerinin anlaşılır mesaja çevrilmesi

v05 ile gelenler:

- Personel ekranları: listeleme, arama, ekleme, düzenleme, silme
- Ada, kimlik numarasına ve departmana göre arama; duruma ve kişi
  türüne göre süzme
- Seçenek listeleri `CHECK` kısıtlarıyla birebir tutulur

v06 ile gelenler:

- Lojman kayıtları: listeleme, süzme, ekleme, düzenleme, silme
- Tarih aralığına göre yatak müsaitliği önizlemesi
- Aynı kişinin çakışan kaydı için önceden uyarı
- Tetikleyici hata kodlarının anlaşılır mesaja çevrilmesi

v07 ile gelenler:

- Arıza kayıtları: listeleme, süzme, ekleme, düzenleme, silme
- Kayıttan önce çakışan arıza (`52001`) uyarısı
- Kayıttan önce "bu arıza kimleri etkileyecek" listesi
- `VW_ARIZA_TASINMASI_GEREKENLER` üzerinden taşınması gerekenler ekranı

v08 ile gelenler:

- İşlem kayıtları ekranı: tarih, kullanıcı, modül, işlem, tablo,
  sonuç ve serbest metne göre süzme
- Sayfalama (sayfa başına 50 kayıt)
- Ayrıntı ekranında eski/yeni değerlerin alan alan karşılaştırması
- Aynı istek kimliğine ait diğer kayıtların izi

v09 ile gelenler:

- Dört rapor: doluluk özeti, yerleşim listesi, açık arızalar,
  giriş çıkış hareketleri
- Her rapor için CSV indirme (`RAPORLAR.RAPOR_AL` yetkisi gerekir)
- Tek şablonla çalışan rapor altyapısı

Bununla birlikte bütün modüller tamamlanmıştır.

## Rapor altyapısı

Her rapor `app/raporlar.py` içinde bir `Rapor` nesnesiyle tanımlanır:
kodu, adı, hangi parametreyi istediği ve hangi sütunları döndürdüğü.
Tek bir şablon bütün raporları çizer, dolayısıyla yeni rapor eklemek
bir SQL sorgusu ve birkaç satır tanımdan ibarettir.

Raporların tamamı belirli bir tarih için fotoğraf çeker. Açık uçlu
lojman ve arıza kayıtlarında çıkış tarihi `NULL`'dur ve tetikleyicilerle
aynı şekilde `31.12.9999` kabul edilir; böylece rapor ile iş kuralları
aynı tarihi aynı biçimde yorumlar.

## CSV neden noktalı virgülle üretiliyor

Türkçe Windows kurulumunda Excel, liste ayırıcı olarak noktalı virgül
bekler; virgülle ayrılmış dosyada bütün satır tek hücreye düşer.
Ayrıca UTF-8 dosyayı BOM olmadan çoğu zaman yanlış kod sayfasıyla açar
ve Türkçe karakterler bozulur. Bu yüzden çıktı `utf-8-sig` kodlaması ve
`;` ayırıcıyla üretilir.

## Yetki durumu

Uygulama `YETKI` tablosundaki 38 yetkiden 31'ini kullanır. Kullanılmayan
7'sinin tamamı tekil modüllerin `RAPOR_AL` yetkileridir
(`PERSONEL.RAPOR_AL` gibi); dışa aktarma şu an merkezi olarak
`RAPORLAR.RAPOR_AL` üzerinden yürür. Liste ekranlarına tek tek CSV
indirme eklenirse bu yetkiler de karşılığını bulur.

## Denetim kaydı okunur hale getirildi

`ESKI_DEGER` ve `YENI_DEGER` veritabanında JSON olarak tutulur. Ham
JSON'u ekrana basmak denetim kaydını okunur kılmaz; uygulama iki
JSON'u alan alan karşılaştırır, değişen alanları listenin başına alır
ve eski değeri üstü çizili, yeni değeri vurgulu gösterir.

Ekleme kaydında eski değer, silme kaydında yeni değer yoktur; bunlar
ayrıca işaretlenir. Bozuk veya beklenmedik biçimdeki JSON ekranı
düşürmez, sadece karşılaştırma yapılamadığı belirtilir.

Parola alanları bu ekranda hiçbir zaman görünmez: tetikleyici adında
`PAROLA`, `SIFRE` veya `PASSWORD` geçen kolonları JSON listesine hiç
almaz, `ISLEM_LOG` üzerindeki `CHECK` kısıtı ve `SP_ISLEM_LOG_EKLE`
bunu ayrıca `54034` ile reddeder.

## İstek izi

Her web isteği kendi `ISTEK_ID` değerini taşır ve tek bir istek birden
fazla tabloyu değiştirmiş olabilir. Ayrıntı ekranı aynı istek
kimliğine ait bütün kayıtları birlikte gösterir; böylece "bu işlem
sırasında başka ne değişti" sorusu tek bakışta yanıtlanır.

## Arıza mevcut yerleşimleri engellemez

`TR_ARIZA_KAYIT_KONTROL` tek bir kural uygular: aynı oda için çakışan
ikinci arıza kaydı olamaz (`52001`). Bir arıza kaydedilirken o odada
zaten duran yerleşimleri **engellemez ve silmez** — 06 numaralı
scriptin kendi yorumu bunu açıkça söyler. Arıza gerçek dünyada olur;
kayıt sistemi onu reddedemez.

Bunun yerine `VW_ARIZA_TASINMASI_GEREKENLER` görünümü, arıza dönemiyle
çakışan mevcut yerleşimleri listeler. Uygulama bu bilgiyi iki yerde
gösterir: kaydetmeden önce uyarı olarak, kaydettikten sonra
"Taşınması gerekenler" ekranında iş listesi olarak.

Ters yönde ise engel vardır: arıza dönemindeki bir odaya **yeni**
lojman kaydı yapılamaz (`51004`).

## Müsaitlik önizlemesi bir kolaylıktır, yetki değildir

`TR_LOJMAN_KAYIT_KONTROL` dört kuralı uygular: pasif hiyerarşi
(`51001`), arıza dönemi çakışması (`51004`), aynı personelin çakışan
kaydı (`51002`) ve yatak kapasitesi (`51003`).

Uygulama aynı kuralları önizleme amacıyla sorgular; kullanıcı dolu bir
yatağı seçip reddedilmeyi beklemesin diye. Ama son söz her zaman
tetikleyicinindir. İki kişi aynı anda kayıt oluşturursa önizleme
ikisine de müsait gösterebilir; tetikleyici birini reddeder ve mesaj
kullanıcıya iletilir.

Açık uçlu kayıtlarda çıkış tarihi `NULL`'dur ve hem tetikleyici hem
önizleme bunu `31.12.9999` olarak değerlendirir.

## Personelde hesaplanan üç alan

`AKTIFPASIF`, `YERLI_YABANCI` ve `PERSONEL_GORUNEN_AD` veritabanında
`PERSISTED` hesaplanan kolonlardır ve yazılamazlar. Bunun arayüzdeki
karşılığı şudur: personel formunda durum seçimi yoktur. Bir kişiyi
pasife almak için işten çıkış tarihi girilir; `AKTIFPASIF` kendiliğinden
`P` olur. Uyruk da kimlik numarasının ilk rakamından gelir.

## Kimlik numarası doğrulaması

Uygulama şemadaki kuralı uygular: tam 11 rakam, sıfırla başlamaz.
T.C. kimlik numarası saklama basamağı algoritması **bilinçli olarak
uygulanmaz**, çünkü şema ilk rakamı 9 olanları `YABANCI` sayar ve
yabancı kimlik numaraları bu algoritmaya uymaz; zorunlu kılmak geçerli
kayıtları reddederdi.

## Tanım tablolarında saklı yordam yok

`KULLANICI` için saklı yordam yazıldı çünkü parola güvenliği ve son
yönetici koruması uygulamaya bırakılamazdı. Tanım tablolarında ise iş
kuralları zaten veritabanındadır: benzersizlik ve değer aralıkları
`CHECK`/`UNIQUE`, hiyerarşi bütünlüğü `FOREIGN KEY`, kapasite ve
çakışma kuralları `TR_LOJMAN_KAYIT_KONTROL` ile korunur. Uygulama
doğrudan `INSERT`/`UPDATE`/`DELETE` yapar; veritabanı yine bekçilik
eder.

Kısıt ihlali yakalandığında hata metni değil, tırnak içindeki kısıt
adı okunur. Böylece çeviri SQL Server'ın arayüz dilinden bağımsız
çalışır.

## Yetki denetimi

Yetki kodları `MODUL_KODU.ISLEM_KODU` biçimindedir (`KULLANICI.EKLE`,
`PERSONEL.GUNCELLE`). Yetkiler oturuma yazılmaz; her istekte
`VW_KULLANICI_YETKILERI` görünümünden okunur. Bir yönetici rolleri
değiştirdiğinde etki anında görülür, kullanıcının çıkıp yeniden
girmesi gerekmez.

## Kilitlenme koruması

10 numaralı script sistemin yönetici olmadan kalmasını engeller:
son aktif sistem yöneticisi kullanıma kapatılamaz (`53154`), rolü
kaldırılamaz (`53164`), kimse kendi hesabını kapatamaz (`53153`) veya
kendi yöneticiliğini bırakamaz (`53163`).

## Veritabanı ön koşulu

v03, `10_KULLANICI_YONETIMI.sql` scriptinin `LOJMANDB` üzerinde
çalıştırılmış olmasını gerektirir.

## Parola akışı

İlk sistem yöneticisi `PAROLA_DEGISTIRMELI = 1` ile oluşturulur. İlk
girişte uygulama parola değiştirme ekranına yönlendirir ve bayrak
indirilene kadar başka bir ekran açılmaz.

Parola değişikliği `KULLANICI` tablosuna doğrudan `UPDATE` olarak
yazılır. `TR_KULLANICI_ISLEM_LOG` bunu `PAROLA_DEGISTIR` işlemi olarak
kaydeder ve hash değeri hiçbir log satırına yazılmaz.

## Kurulum sırası

1. ZIP dosyasını normal bir klasöre tamamen çıkartın.
2. `01_Kurulum.bat` dosyasına çift tıklayın.
3. Sonuçta aşağıdaki mesajı doğrulayın:

   ```text
   [BASARILI] FastAPI v01 on testi tamamlandi.
   ```

4. `02_Uygulamayi_Baslat.bat` dosyasına çift tıklayın.
5. Tarayıcı otomatik açılmazsa şu adresi açın:

   ```text
   http://127.0.0.1:8000
   ```

Uygulamayı durdurmak için çalışan siyah pencerede `Ctrl+C` tuşlarına basın.

## Beklenen ana ekran

Ana ekranda şunlar görünmelidir:

- Sistem durumu: `Hazır`
- Veritabanı: `LOJMANDB`
- SQL Server: `LHFTYNBBPRLP01`
- 12 tablo, 9 görünüm, 6 prosedür ve 14 tetikleyici
- Lokasyon, oda, yatak, personel, aktif yerleşim ve aktif arıza sayıları

## Testler

Kurulumdan sonra istenirse `03_Temel_Testleri_Calistir.bat` çalıştırılabilir.
Bu dosya hem birim testlerini hem de gerçek `LOJMANDB` oturum bağlamı testini
çalıştırır.

## Ayarlar

İlk kurulumda `.env` dosyası otomatik oluşturulur. Varsayılan bağlantı:

```text
SQL_SERVER=.
SQL_DATABASE=LOJMANDB
SQL_DRIVER=
```

`SQL_DRIVER` boşsa bilgisayarda yüklü sürücüler arasından önce ODBC Driver 18,
sonra ODBC Driver 17 seçilir.

SSMS bağlantısı daha sonra değişirse yalnızca `.env` dosyasındaki
`SQL_SERVER` değeri güncellenmelidir. `SESSION_SECRET` değeri paylaşılmamalı
ve kaynak koduna eklenmemelidir.

## Teknik not

Mevcut SQL tabloları, kısıtlar, tetikleyiciler ve prosedürler sistemin veri
doğruluğu kaynağıdır. v01 bu şemayı yeniden oluşturmaz ve otomatik migration
çalıştırmaz. SQLAlchemy bu aşamada güvenli bağlantı, transaction ve sorgu
yönetimi için kullanılır.
