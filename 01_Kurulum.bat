@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo LOJMAN YONETIM SISTEMI - FASTAPI V01 KURULUMU
echo ============================================================

set "PYTHON_CMD=python"
python --version >nul 2>&1
if errorlevel 1 (
    py -3 --version >nul 2>&1
    if errorlevel 1 goto :python_error
    set "PYTHON_CMD=py -3"
)

if not exist ".venv\Scripts\python.exe" (
    echo.
    echo Python sanal ortami olusturuluyor...
    %PYTHON_CMD% -m venv .venv
    if errorlevel 1 goto :install_error
)

echo.
echo Gerekli Python paketleri kuruluyor...
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -r requirements.txt
if errorlevel 1 goto :install_error

echo.
echo Yerel ortam ayarlari kontrol ediliyor...
".venv\Scripts\python.exe" scripts\create_env.py
if errorlevel 1 goto :install_error

echo.
echo SQL Server ve FastAPI on testi calistiriliyor...
".venv\Scripts\python.exe" -m app.preflight
if errorlevel 1 goto :preflight_error

echo.
echo ============================================================
echo [BASARILI] FastAPI v01 kurulumu tamamlandi.
echo Simdi 02_Uygulamayi_Baslat.bat dosyasini calistirin.
echo ============================================================
pause
exit /b 0

:python_error
echo.
echo [HATA] Python bulunamadi.
echo Python'un kurulu ve PATH ayarinin yapilmis oldugunu kontrol edin.
pause
exit /b 1

:preflight_error
echo.
echo [HATA] On test basarisiz oldu.
echo Yukaridaki hata mesajinin tamamini paylasin.
pause
exit /b 1

:install_error
echo.
echo [HATA] Kurulum tamamlanamadi.
echo Yukaridaki hata mesajinin tamamini paylasin.
pause
exit /b 1
