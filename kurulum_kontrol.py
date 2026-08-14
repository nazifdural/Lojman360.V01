"""Kurulumun eksiksiz olup olmadigini bildirir."""
import pathlib
import sys

# (dosya, iceride ARANAN metin, ne oldugu)
BEKLENENLER = [
    ("app/templates/base.html", "app_surum_damgasi", "alt seritteki surum"),
    ("app/config.py", "app_surum_damgasi", "surum ayari"),
    ("app/main.py", 'filters["ozel_ad_yaz"]', "ozel ad suzgeci tanitimi"),
    ("app/tanimlar.py", "def ozel_ad_yaz", "ozel ad bicimlendirici"),
    ("app/static/css/app.css", "baslik-sirket", "baslik sirket bicimi"),
    ("app/static/css/app.css", "--cerceve:", "kenarlik rengi"),
    ("app/static/js/satir_hizli.js", "data-hizli-alanlar", "hizli guncelleme"),
    ("app/templates/yataklar.html", "baslik-sirket", "baslikta sirket adi"),
    ("app/rapor_kurucu.py", "TEMELLER", "rapor kurucu"),
    # PARCA SABLONLAR
    # Ana ekran makro dosyasini kullanmiyor; diger butun sayfalar
    # kullaniyor. Bu dosya eski kalirsa yalnizca ana ekran acilir,
    # geri kalan her sayfa 500 verir.
    ("app/templates/_form_makro.html", "macro dugme_grubu",
     "dugme grubu makrosu"),
    ("app/templates/_simgeler.html", "macro simge_erkek",
     "cinsiyet simgeleri"),
    ("app/templates/base.html", "satir_hizli.js", "hizli guncelleme betigi"),
    ("app/templates/base.html", "ozel_ad_yaz", "sekme basliginda sirket"),
    ("app/templates/rapor_calistir.html", "SÜTUN SÜZGEÇLERİ",
     "kayitli rapor ekrani"),
    ("app/templates/ariza_kayitlari.html", "data-hizli", "ariza hizli"),
    ("app/templates/lojman_kayitlari.html", "data-hizli", "lojman hizli"),
    ("app/queries.py", "ARIZA_TARIH_GUNCELLE", "ariza tarih sorgusu"),
    ("app/lojman.py", "async def hizli_guncelle", "lojman hizli guncelleme"),
    ("app/ariza.py", "async def hizli_guncelle", "ariza hizli guncelleme"),
    ("app/yerlesim.py", "def _bloklara_ayir", "blok gruplama"),
    ("app/preflight.py", "async with engine.connect() as connection",
     "on test baglanti kapsami"),
    # 20 numarali script sonrasi
    ("app/personel.py", "def _misafir_coz", "misafir bagi"),
    ("app/personel.py", "async def cikis_yap", "personel cikis islemi"),
    ("app/personel.py", "_zorunlu_kapali_liste", "zorunlu departman"),
    ("app/templates/personel_cikis.html", "data-cikis-kaynak",
     "personel cikis ekrani"),
    ("app/templates/personel_form.html", "data-misafir-alani",
     "formda misafir alani"),
    ("app/static/js/personel_form.js", "personel-tckn-denetle",
     "mukerrer kimlik denetimi"),
    ("app/static/js/personel_cikis.js", "data-cikis-lojman",
     "cikis tarih eslestirme"),
    ("app/queries.py", "MISAFIR_BAG_SECENEKLERI", "misafir secenekleri"),
]

# Betik proje kokunde duruyor.
# ZIP acmak dosya EKLER, SILMEZ. Bir dosya artik kullanilmiyorsa
# kullanicinin diskinde kalir; testler bunu yakalar ama sebebi
# anlasilmaz. Burada acikca soyluyoruz.
# ESKI SURUM ISARETLERI
# Dosya icinde ARTIK OLMAMASI gereken metinler. "Yeni sey var mi"
# denetimi bunlari kacirryor: dosya kismen guncellenmis olabilir.
KALDIRILANLAR = [
    ("app/queries.py", "[ARAC_PLAKA]          = :arac_plaka",
     "personel guncelleme sorgusunda eski plaka kolonu"),
    ("app/queries.py", ":arac_plaka, :kisi_turu",
     "personel ekleme sorgusunda eski plaka kolonu"),
    ("app/main.py", '"arac_plaka", "kisi_turu"',
     "PERSONEL_ALANLARI icinde eski plaka alani"),
    ("app/templates/personel_form.html", "'İşten çıkış tarihi'",
     "personel formunda isten cikis tarihi"),
]

ARTIKLAR = [
    ("app/static/js/lojman_satir.js",
     "yerine satir_hizli.js geldi (arizada da kullaniliyor)"),
]

kok = pathlib.Path(__file__).resolve().parent
eksik = []
artik = []

print("=" * 58)
print("AND360 - KURULUM KONTROLU")
print("=" * 58)
print()

for yol, aranan, aciklama in BEKLENENLER:
    tam = kok / yol
    if not tam.exists():
        print(f"  >>> EKSIK DOSYA  {yol}")
        eksik.append(yol)
        continue
    metin = tam.read_text(encoding="utf-8", errors="ignore")
    if aranan in metin:
        print(f"  TAMAM  {aciklama}")
    else:
        print(f"  >>> ESKI SURUM   {yol}  ({aciklama})")
        eksik.append(yol)

eski_surum = []
for yol, aranan, aciklama in KALDIRILANLAR:
    tam = kok / yol
    if not tam.exists():
        continue
    if aranan in tam.read_text(encoding="utf-8", errors="ignore"):
        print(f"  >>> ESKI SURUM   {yol}")
        print(f"                   ({aciklama} hala duruyor)")
        eski_surum.append(yol)

for yol, sebep in ARTIKLAR:
    tam = kok / yol
    if tam.exists():
        print(f"  >>> SILINMELI    {yol}")
        print(f"                   ({sebep})")
        artik.append(yol)

print()
if eski_surum:
    print("Asagidaki dosyalar GUNCELLENMEMIS:")
    for yol in sorted(set(eski_surum)):
        print("   ", yol.replace("/", "\\"))
    print()
    print("ZIP icindeki app klasorunu KOPYALAYIP UZERINE YAZIN.")
    print()

if artik:
    print("Asagidaki dosyalar ARTIK KULLANILMIYOR, silin:")
    for yol in artik:
        print("   ", yol.replace("/", "\\"))
    print()

if eksik:
    print("Asagidaki dosyalar guncellenmemis:")
    for yol in sorted(set(eksik)):
        print("   ", yol)
    print()
    print("ZIP icindeki app ve tests klasorlerini proje klasorune")
    print("kopyalayip UZERINE YAZDIRIN.")
elif not artik and not eski_surum:
    print("Kurulum eksiksiz.")
print()
input("Kapatmak icin Enter'a basin...")
sys.exit(1 if (eksik or artik or eski_surum) else 0)
