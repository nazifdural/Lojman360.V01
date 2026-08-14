@echo off
chcp 65280 >nul 2>&1
rem ===================================================================
rem  AND360 - KALDIRILAN DOSYALARI SIL
rem
rem  NEDEN GEREKLI
rem  Zip acmak dosya EKLER, silinenleri kaldirmaz. Kaldirilan bir
rem  sablon klasorde kalirsa uygulama onu taramaya devam eder ve
rem  acilista hata verir:
rem
rem     Sablonlarin kullandigi bazi suzgecler tanitilmamis:
rem       yikama_durum_yaz  (yikama_parti.html)
rem
rem  Bu betik yalnizca ARTIK KULLANILMAYAN dosyalari siler.
rem  Veriye ya da veritabanina dokunmaz.
rem ===================================================================

setlocal
set KOK=%~dp0
if exist "%KOK%app\templates\" goto BULUNDU
set KOK=C:\Lojman\LojmanYonetim_FastAPI_v01\
if exist "%KOK%app\templates\" goto BULUNDU

echo.
echo   Proje klasoru bulunamadi.
echo   Bu dosyayi proje klasorune kopyalayip tekrar calistirin.
echo.
pause
exit /b 1

:BULUNDU
echo.
echo   Proje: %KOK%
echo.

call :SIL "%KOK%app\templates\yikama_parti.html"     "Parti ekrani (parti takibi kaldirildi)"
call :SIL "%KOK%app\templates\stok_durumu.html"      "Stok durumu ekrani"
call :SIL "%KOK%app\templates\depo_hareketleri.html" "Depo hareketleri ekrani"
call :SIL "%KOK%app\templates\camasirhane_defteri.html" "Ayri defter ekrani (yikamaya tasindi)"

echo.
echo   Bitti. Uygulamayi TAMAMEN durdurup yeniden baslatin.
echo.
pause
exit /b 0

:SIL
if exist %1 (
    del /q %1
    echo   silindi : %~nx1  -  %~2
) else (
    echo   zaten yok: %~nx1
)
exit /b 0
