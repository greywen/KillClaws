@echo off
title KillClaws - Remove All Claw AI Products
echo.
echo  KillClaws - One command to remove all Claw AI products
echo  ======================================================
echo.

:: Check if killclaws.ps1 exists in the same directory
if exist "%~dp0killclaws.ps1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0killclaws.ps1"
) else (
    echo  killclaws.ps1 not found, downloading latest version...
    echo.
    powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1' -OutFile '%TEMP%\killclaws.ps1'; powershell -ExecutionPolicy Bypass -File '%TEMP%\killclaws.ps1'"
)

echo.
pause
