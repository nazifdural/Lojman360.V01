@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo AND360 - UYGULAMAYI DURDUR
echo ============================================================
echo.

rem Sessiz baslatmada Ctrl+C basacak pencere yok; surec adiyla
rem durduruluyor. Yalnizca BU KLASORDEKI sanal ortamin python'u
rem hedefleniyor -- bilgisayardaki diger python programlari
rem etkilenmesin.

set "HEDEF=%~dp0.venv\Scripts\python.exe"
set BULUNDU=0

for /f "skip=1 tokens=1 delims=," %%P in (
    'wmic process where "ExecutablePath='%HEDEF:\=\\%'" get ProcessId /format:csv 2^>nul'
) do (
    for /f "tokens=2 delims=," %%Q in ("%%P") do (
        if not "%%Q"=="" (
            taskkill /PID %%Q /T /F >nul 2>&1
            set BULUNDU=1
        )
    )
)

rem wmic yeni Windows surumlerinde kaldirilmis olabilir; yedek yol.
if "%BULUNDU%"=="0" (
    powershell -NoProfile -Command ^
      "$h='%HEDEF%'; $p=Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $h }; if ($p) { $p | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }; 'durduruldu' } else { 'calisan yok' }"
) else (
    echo Uygulama durduruldu.
)

echo.
pause
