@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

rem ZIP acmak dosya EKLER, SILMEZ. Artik kullanilmayan dosyalar
rem diskte kalir. Bu betik onlari siler.

echo ============================================================
echo AND360 - ARTIK DOSYALARI TEMIZLE
echo ============================================================
echo.

set SAYAC=0

call :sil "app\static\js\lojman_satir.js"

echo.
if "%SAYAC%"=="0" (
    echo Silinecek dosya yok.
) else (
    echo %SAYAC% dosya silindi.
)
echo.
pause
exit /b 0

:sil
if exist "%~1" (
    del /q "%~1"
    echo   Silindi: %~1
    set /a SAYAC+=1
) else (
    echo   Zaten yok: %~1
)
exit /b 0
