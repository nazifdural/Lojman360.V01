"""Unutulan yonetici parolasini sifirlar.

NE ZAMAN KULLANILIR
Sistem yoneticisi parolasini unuttugunda ve baska yonetici hesabi
kalmadiginda. Uygulama uzerinden sifirlama yolu yok -- bu bilincli
bir tercih; parola sifirlama ekrani saldiri yuzeyi olurdu.

NEDEN AYRI BETIK
Parola dogrudan SQL ile degistirilemez: PAROLA_HASH argon2 ile
uretiliyor ve elle yazilamaz. Bu betik uygulamanin KENDI hash
islevini kullaniyor, boylece bicim her zaman tutarli kaliyor.

CALISTIRMA
Proje kokunde, sanal ortamla:

    .venv\\Scripts\\python parola_sifirla.py

Kullanici adini ve yeni parolayi sorar.

GUVENLIK
Betigi sunucuda birakmayin. Isiniz bitince silin ya da erisimi
yalnizca yoneticiyle sinirlayin -- veritabanina erisebilen
herkesin her hesabin parolasini degistirmesine yol acar.
"""

from __future__ import annotations

import asyncio
import getpass
import sys

from sqlalchemy import text

from app.auth import hash_uret
from app.security import (
    PAROLA_ASGARI_UZUNLUK,
    ParolaKuralHatasi,
    parolayi_denetle,
)
from app.config import get_settings
from app.database import create_db_engine


async def _sifirla(kullanici_adi: str, yeni_parola: str) -> None:
    ayarlar = get_settings()
    motor = create_db_engine(ayarlar)

    try:
        async with motor.begin() as baglanti:
            # BAKIM BAGLAMI
            # KULLANICI tablosu satir guvenligine tabi olmasa da
            # tetikleyiciler oturum baglamini okuyor. Bakim
            # bayragi olmadan islem kaydi "SISTEM" olarak
            # yaziliyor -- bu dogru, degistirmiyoruz.
            satir = (
                await baglanti.execute(
                    text(
                        "SELECT [KULLANICI_ID], [ADI_SOYADI], [AKTIFPASIF] "
                        "FROM [dbo].[KULLANICI] "
                        "WHERE [KULLANICI_ADI] = :ad;"
                    ),
                    {"ad": kullanici_adi},
                )
            ).mappings().first()

            if satir is None:
                print(f"Kullanıcı bulunamadı: {kullanici_adi}")
                _kullanicilari_yaz(baglanti)
                return

            sonuc = await baglanti.execute(
                text(
                    "UPDATE [dbo].[KULLANICI] "
                    "SET [PAROLA_HASH] = :hash, "
                    "    [BASARISIZ_GIRIS_SAYISI] = 0, "
                    "    [KILIT_BITIS_ZAMANI] = NULL, "
                    # Yeni parola ilk giriste degistirilsin.
                    "    [PAROLA_DEGISTIRMELI] = 1 "
                    "WHERE [KULLANICI_ID] = :kimlik;"
                ),
                {
                    "hash": hash_uret(yeni_parola),
                    "kimlik": satir["KULLANICI_ID"],
                },
            )

            if sonuc.rowcount == 0:
                print("Hiçbir kayıt güncellenmedi.")
                return

            print()
            print(f"Parola sıfırlandı: {kullanici_adi}")
            print(f"  Ad soyad : {satir['ADI_SOYADI']}")
            print(f"  Durum    : {satir['AKTIFPASIF']}")
            print()
            print("İlk girişte parola değiştirmeniz istenecek.")
            if satir["AKTIFPASIF"] != "A":
                print()
                print(">>> UYARI: hesap PASİF. Giriş yapılamaz;")
                print("    veritabanından AKTIFPASIF = 'A' yapın.")
    finally:
        await motor.dispose()


async def _kullanicilari_listele() -> None:
    """Hangi kullanicilar var, gormek icin."""
    ayarlar = get_settings()
    motor = create_db_engine(ayarlar)
    try:
        async with motor.connect() as baglanti:
            satirlar = (
                await baglanti.execute(
                    text(
                        "SELECT [KULLANICI_ADI], [ADI_SOYADI], [AKTIFPASIF] "
                        "FROM [dbo].[KULLANICI] "
                        "ORDER BY [KULLANICI_ADI];"
                    )
                )
            ).mappings().all()

            print()
            print("KAYITLI KULLANICILAR")
            for s in satirlar:
                durum = "etkin" if s["AKTIFPASIF"] == "A" else "pasif"
                print(f"  {s['KULLANICI_ADI']:<24} "
                      f"{s['ADI_SOYADI'] or '':<28} {durum}")
    finally:
        await motor.dispose()


def _kullanicilari_yaz(baglanti) -> None:
    """Hata durumunda ipucu."""
    print("Kullanıcı listesini görmek için:")
    print("  .venv\\Scripts\\python parola_sifirla.py --liste")


def main() -> int:
    if "--liste" in sys.argv:
        asyncio.run(_kullanicilari_listele())
        return 0

    print("AND360 — parola sıfırlama")
    print()

    kullanici_adi = input("Kullanıcı adı: ").strip()
    if not kullanici_adi:
        print("Kullanıcı adı boş olamaz.")
        return 1

    # PAROLA EKRANDA GORUNMUYOR
    # getpass, girilen metni yazdirmiyor; omuz ustunden okunmasin.
    yeni = getpass.getpass("Yeni parola: ")
    tekrar = getpass.getpass("Yeni parola (tekrar): ")

    if yeni != tekrar:
        print("Parolalar eşleşmiyor.")
        return 1

    # UYGULAMANIN KENDI KURALLARI
    # Uzunluk, karmasiklik, kullanici adini icermeme -- hepsi
    # parolayi_denetle icinde. Burada ayrica yazilsaydi ikisi
    # ayrisirdi.
    try:
        parolayi_denetle(yeni, kullanici_adi)
    except ParolaKuralHatasi as sorun:
        print(f"Parola kabul edilmedi: {sorun}")
        print(f"En az {PAROLA_ASGARI_UZUNLUK} karakter olmalı.")
        return 1

    asyncio.run(_sifirla(kullanici_adi, yeni))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
