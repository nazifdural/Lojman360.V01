@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo AND360 - TEMIZ BASLATMA
echo ============================================================
echo.

rem --- 1. Calisan butun python sureclerini durdur -------------
echo [1/4] Calisan surecler durduruluyor...
taskkill /F /IM python.exe /T >nul 2>&1
taskkill /F /IM pythonw.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul
echo       tamam.

rem --- 2. 8000 portu bosaldi mi ------------------------------
echo [2/4] 8000 portu denetleniyor...
set PORT_DOLU=0
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8000 .*LISTENING"') do (
    set PORT_DOLU=1
    echo       >>> Port hala dolu. Tutan surec: %%P
    taskkill /F /PID %%P >nul 2>&1
    echo       Surec %%P durduruldu.
)
if "%PORT_DOLU%"=="0" echo       port bos.

rem --- 3. Eski gunlukleri temizle -----------------------------
echo [3/4] Eski gunlukler siliniyor...
if not exist "gunluk" mkdir "gunluk"
if exist "gunluk\sunucu.log" del /q "gunluk\sunucu.log"
if exist "gunluk\hata.log" del /q "gunluk\hata.log"
rem Python onbellegi de temizlensin: eski .pyc kalmasin.
for /d /r "app" %%D in (__pycache__) do @if exist "%%D" rd /s /q "%%D"
echo       tamam.

rem --- 4. Baslat ----------------------------------------------
echo [4/4] Uygulama baslatiliyor...
echo.
".venv\Scripts\python.exe" -m scripts.run_server
if errorlevel 1 (
    echo.
    echo [HATA] Uygulama baslatilamadi.
    echo Yukaridaki mesajin tamamini paylasin.
)
echo.
pause
