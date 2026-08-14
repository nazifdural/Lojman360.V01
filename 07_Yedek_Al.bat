@echo off
chcp 65001 > nul
setlocal

REM ============================================================
REM  LOJMANDB YEDEK AL
REM
REM  SQL Server Express'te SQL Server Agent yok; zamanlanmis
REM  yedekleme bu dosya ile Windows Gorev Zamanlayici uzerinden
REM  yapiliyor.
REM
REM  ZAMANLAMA KURULUMU
REM    1. Gorev Zamanlayici'yi acin (taskschd.msc).
REM    2. "Temel Gorev Olustur" -> ad: LOJMANDB Yedek
REM    3. Tetikleyici: Gunluk, saat 03:00
REM    4. Eylem: Program baslat -> bu dosyanin tam yolu
REM    5. "En yuksek ayricaliklarla calistir" isaretli olsun.
REM    6. "Kullanici oturum acmis olsun olmasin calistir" secin.
REM
REM  ONEMLI: Gorevi calistiracak hesabin LOJMANDB uzerinde
REM  yedek alma yetkisi olmali.
REM ============================================================

set SUNUCU=.
set VERITABANI=LOJMANDB
set KLASOR=C:\Lojman\Yedek
set SAKLAMA_GUN=30

echo.
echo  LOJMANDB yedekleme
echo  ------------------

if not exist "%KLASOR%" (
    echo  Yedek klasoru olusturuluyor: %KLASOR%
    mkdir "%KLASOR%" 2>nul
    if errorlevel 1 (
        echo  HATA: Klasor olusturulamadi.
        exit /b 1
    )
)

REM Tarih damgasi: yil-ay-gun_saat-dakika
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set DT=%%I
set DAMGA=%DT:~0,8%_%DT:~8,4%
set DOSYA=%KLASOR%\%VERITABANI%_%DAMGA%.bak

echo  Hedef: %DOSYA%
echo.

REM -E : Windows kimlik dogrulamasi
REM -b : hata olursa cikis kodu dondur (gorev zamanlayici gorsun)
sqlcmd -S %SUNUCU% -E -b -Q ^
"BACKUP DATABASE [%VERITABANI%] TO DISK = N'%DOSYA%' WITH INIT, CHECKSUM, STATS = 10;"

if errorlevel 1 (
    echo.
    echo  HATA: Yedek alinamadi.
    exit /b 1
)

REM DOGRULAMA
REM Alinamayan yedek yedek degildir. Dosya burada okunup
REM butunlugu kontrol ediliyor; atlanirsa bozuk yedegin bozuk
REM oldugu ancak kurtarma gunu anlasilir.
echo.
echo  Yedek dogrulaniyor...
sqlcmd -S %SUNUCU% -E -b -Q ^
"RESTORE VERIFYONLY FROM DISK = N'%DOSYA%' WITH CHECKSUM;"

if errorlevel 1 (
    echo.
    echo  HATA: Yedek DOGRULANAMADI. Dosya bozuk olabilir.
    exit /b 1
)

REM ESKI YEDEKLERI TEMIZLE
REM Once dogrulama, sonra temizlik: yeni yedek saglam degilse
REM eskiler silinmemeli.
echo.
echo  %SAKLAMA_GUN% gunden eski yedekler siliniyor...
forfiles /p "%KLASOR%" /m *.bak /d -%SAKLAMA_GUN% /c "cmd /c del @path" 2>nul

echo.
echo  TAMAM: %DOSYA%
echo.
exit /b 0
