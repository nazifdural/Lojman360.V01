@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo LOJMAN YONETIM SISTEMI - FASTAPI V01 TESTLERI
echo ============================================================

if not exist ".venv\Scripts\python.exe" (
    echo.
    echo [HATA] Once 01_Kurulum.bat dosyasini calistirin.
    pause
    exit /b 1
)

echo.
echo Birim testleri calistiriliyor...
".venv\Scripts\python.exe" -m unittest discover -s tests -v
if errorlevel 1 goto :test_error

echo.
echo JavaScript testleri calistiriliyor...
where node >nul 2>&1
if errorlevel 1 (
    echo [ATLANDI] Node.js kurulu degil. JavaScript testleri calistirilmadi.
    echo           Uygulamanin calismasi icin Node.js GEREKMEZ; bu testler
    echo           yalnizca tarayici tarafi mantigini dogrular.
) else (
    node tests\test_suruklebirak.js
    if errorlevel 1 goto :test_error
    node tests\test_sutunlar.js
    if errorlevel 1 goto :test_error
    node tests\test_surukleme_akisi.js
    if errorlevel 1 goto :test_error
    node tests\test_toplu_acma.js
    if errorlevel 1 goto :test_error
    node tests\test_harita.js
    if errorlevel 1 goto :test_error
    node tests\test_oda_satir.js
    if errorlevel 1 goto :test_error
    node tests\test_secim_serit.js
    if errorlevel 1 goto :test_error
    node tests\test_sutun_tasima.js
    if errorlevel 1 goto :test_error
    node tests\test_hizli_dugme.js
    if errorlevel 1 goto :test_error
    node tests\test_sutun_secici.js
    if errorlevel 1 goto :test_error
    node tests\test_cip_birakma.js
    if errorlevel 1 goto :test_error
)

echo.
echo Canli SQL Server on testi calistiriliyor...
".venv\Scripts\python.exe" -m app.preflight
if errorlevel 1 goto :test_error

echo.
echo [BASARILI] Tum FastAPI v01 testleri tamamlandi.
pause
exit /b 0

:test_error
echo.
echo [HATA] En az bir test basarisiz oldu.
echo Yukaridaki hata mesajinin tamamini paylasin.
pause
exit /b 1
