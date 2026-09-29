@echo off
:: Crea-Sorgenti.cmd by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0b9 - 2026-09-29 13:37:52
setlocal enabledelayedexpansion
title Creazione zip sorgenti X-Submarine

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

set "INI_FILE=%ROOT%\X-Submarine\x-launcher.ini"
set "RELEASES_DIR=%ROOT%\releases"
set "STAGING_DIR=%RELEASES_DIR%\_staging-sorgenti"

echo =======================================================
echo     Creazione zip sorgenti X-Submarine
echo =======================================================
echo.

if not exist "%INI_FILE%" (
    echo [ERRORE] Non trovo %INI_FILE%
    pause
    exit /b 1
)

:: -------------------------------------------------------------
:: [1/4] Nome del file, nello stesso formato del pacchetto sorgente
:: ufficiale winPenPack ^(es. X-Firefox_launcher_1.5.4_rev8.source.zip^)
:: -------------------------------------------------------------
echo [1/4] Calcolo nome del file...

set "LAUNCHER_VER="
for /f "tokens=2 delims==" %%L in ('findstr /b /i "Launcher=" "%INI_FILE%"') do set "LAUNCHER_VER=%%L"
if "%LAUNCHER_VER%"=="" set "LAUNCHER_VER=0.0.0"

set "INI_REV="
for /f "tokens=2 delims==" %%R in ('findstr /b /i "Ini Revision=" "%INI_FILE%"') do set "INI_REV=%%R"
if "%INI_REV%"=="" set "INI_REV=0"

set "SOURCE_NAME=X-Submarine_launcher_%LAUNCHER_VER%_rev%INI_REV%.source"
set "ZIP_FILE=%RELEASES_DIR%\%SOURCE_NAME%.zip"

echo       Nome file: %SOURCE_NAME%.zip
echo.

:: -------------------------------------------------------------
:: [2/4] Prepara lo staging: X-Submarine\, _x-launcher\, Readme\
:: ^(stessa struttura del pacchetto sorgente ufficiale^), piu' il
:: nostro README.md del progetto copiato dentro Readme\.
:: -------------------------------------------------------------
echo [2/4] Preparazione della struttura sorgenti...

if exist "%STAGING_DIR%" rmdir /s /q "%STAGING_DIR%"
mkdir "%STAGING_DIR%"

xcopy "%ROOT%\X-Submarine" "%STAGING_DIR%\X-Submarine\" /e /i /y > nul
xcopy "%ROOT%\_x-launcher" "%STAGING_DIR%\_x-launcher\" /e /i /y > nul
xcopy "%ROOT%\Readme" "%STAGING_DIR%\Readme\" /e /i /y > nul

:: Il nostro README.md di progetto, dentro Readme\, accanto ai
:: readme generici winPenPack ^(non li sostituisce, si aggiunge^)
copy /y "%ROOT%\README.md" "%STAGING_DIR%\Readme\README_X-Submarine.md" > nul

:: L'exe compilato non fa parte dei "sorgenti": se presente, non copiarlo
if exist "%STAGING_DIR%\X-Submarine\X-Submarine.exe" del /q "%STAGING_DIR%\X-Submarine\X-Submarine.exe"

:: -------------------------------------------------------------
:: [3/4] Ricerca di 7-Zip
:: -------------------------------------------------------------
echo [3/4] Ricerca di 7-Zip...

set "SEVENZIP="
if exist "C:\Program Files\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if "%SEVENZIP%"=="" if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
if "%SEVENZIP%"=="" (
    for /f "delims=" %%W in ('where 7z.exe 2^>nul') do if "%SEVENZIP%"=="" set "SEVENZIP=%%W"
)
if "%SEVENZIP%"=="" if not "%WINPENPACK_7ZIP%"=="" if exist "%WINPENPACK_7ZIP%" set "SEVENZIP=%WINPENPACK_7ZIP%"

if "%SEVENZIP%"=="" (
    echo [ERRORE] 7-Zip non trovato ^(installazione locale, PATH, o variabile WINPENPACK_7ZIP^).
    pause
    exit /b 1
)
echo       Uso 7-Zip: %SEVENZIP%
echo.

:: -------------------------------------------------------------
:: [4/4] Crea lo zip
:: -------------------------------------------------------------
echo [4/4] Creazione dello zip...

if not exist "%RELEASES_DIR%" mkdir "%RELEASES_DIR%"
if exist "%ZIP_FILE%" del /q "%ZIP_FILE%"

pushd "%STAGING_DIR%"
"%SEVENZIP%" a -tzip "%ZIP_FILE%" ".\*" -mx=9 > nul
popd

rmdir /s /q "%STAGING_DIR%"

if not exist "%ZIP_FILE%" (
    echo [ERRORE] Creazione dello zip fallita.
    pause
    exit /b 1
)

echo.
echo Zip sorgenti creato: %ZIP_FILE%

endlocal
