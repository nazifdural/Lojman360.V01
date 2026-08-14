@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

rem Guncellemenin eksiksiz kurulup kurulmadigini bildirir.
rem Sanal ortam gerekmiyor; yalnizca dosya icerigine bakiyor.

where python >nul 2>&1
if errorlevel 1 (
    ".venv\Scripts\python.exe" kurulum_kontrol.py
) else (
    python kurulum_kontrol.py
)
