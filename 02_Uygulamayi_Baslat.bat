@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo LOJMAN YONETIM SISTEMI - FASTAPI V01
echo ============================================================

if not exist ".venv\Scripts\python.exe" (
    echo.
    echo [HATA] Kurulum bulunamadi.
    echo Once 01_Kurulum.bat dosyasini calistirin.
    pause
    exit /b 1
)

if not exist ".env" (
    echo.
    echo [HATA] .env ayar dosyasi bulunamadi.
    echo Once 01_Kurulum.bat dosyasini calistirin.
    pause
    exit /b 1
)

".venv\Scripts\python.exe" -m scripts.run_server
if errorlevel 1 (
    echo.
    echo [HATA] Uygulama baslatilamadi.
    echo Yukaridaki hata mesajinin tamamini paylasin.
)

pause
