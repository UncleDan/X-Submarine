@echo off
:: Crea-Release.cmd by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0b9 - 2026-09-29 13:37:52
setlocal enabledelayedexpansion
title Creazione release X-Submarine

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

set "SRC_DIR=%ROOT%\X-Submarine"
set "EXE_FILE=%SRC_DIR%\X-Submarine.exe"
set "INI_FILE=%SRC_DIR%\x-launcher.ini"
set "RELEASES_DIR=%ROOT%\releases"
set "STAGING_DIR=%RELEASES_DIR%\_staging"

echo =======================================================
echo     Creazione pacchetto di distribuzione X-Submarine
echo =======================================================
echo.

:: -------------------------------------------------------------
:: [1/5] Compila il launcher ^(sempre, per garantire un binario aggiornato^)
:: -------------------------------------------------------------
echo [1/5] Compilazione del launcher...
call "%~dp0Compila-Launcher.cmd"
if errorlevel 1 (
    echo [ERRORE] Compilazione fallita, release interrotta.
    pause
    exit /b 1
)
echo.

if not exist "%EXE_FILE%" (
    echo [ERRORE] %EXE_FILE% non trovato dopo la compilazione.
    pause
    exit /b 1
)
if not exist "%INI_FILE%" (
    echo [ERRORE] %INI_FILE% non trovato.
    pause
    exit /b 1
)

:: -------------------------------------------------------------
:: [2/5] Versione e timestamp per il nome del file
:: -------------------------------------------------------------
echo [2/5] Calcolo versione e timestamp...

:: Versione del pacchetto = campo "Ini Revision" dell'ini (es. 1.0b9)
set "PKG_VERSION="
for /f "tokens=2 delims==" %%R in ('findstr /b /i "Ini Revision=" "%INI_FILE%"') do set "PKG_VERSION=%%R"
if "%PKG_VERSION%"=="" set "PKG_VERSION=dev"

:: Timestamp in ora locale ^(assunta = fuso Roma sulla macchina di build^) via PowerShell, formato affidabile indipendente dal locale
for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format \"yyyyMMdd-HHmm\""') do set "TIMESTAMP=%%T"

set "RELEASE_NAME=X-Submarine_%PKG_VERSION%_win32_%TIMESTAMP%"
set "ZIP_FILE=%RELEASES_DIR%\%RELEASE_NAME%.zip"

echo       Nome release: %RELEASE_NAME%
echo.

:: -------------------------------------------------------------
:: [3/5] Prepara la struttura di staging nel percorso corretto
:: -------------------------------------------------------------
echo [3/5] Preparazione della struttura di distribuzione...

if exist "%STAGING_DIR%" rmdir /s /q "%STAGING_DIR%"
mkdir "%STAGING_DIR%"

copy /y "%EXE_FILE%" "%STAGING_DIR%\X-Submarine.exe" > nul
copy /y "%INI_FILE%" "%STAGING_DIR%\X-Submarine.ini" > nul

mkdir "%STAGING_DIR%\Bin\Submarine"
copy /y "%ROOT%\Bin\Submarine\Init_Submarine.bat" "%STAGING_DIR%\Bin\Submarine\Init_Submarine.bat" > nul

mkdir "%STAGING_DIR%\User\Submarine\Profile"
mkdir "%STAGING_DIR%\User\Submarine\AppData\Roaming"
mkdir "%STAGING_DIR%\User\Submarine\AppData\Local"

:: -------------------------------------------------------------
:: [4/5] Ricerca di 7-Zip: prima installazione locale, poi winPenPack
:: -------------------------------------------------------------
echo [4/5] Ricerca di 7-Zip...

set "SEVENZIP="
if exist "C:\Program Files\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if "%SEVENZIP%"=="" if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
if "%SEVENZIP%"=="" (
    for /f "delims=" %%W in ('where 7z.exe 2^>nul') do if "%SEVENZIP%"=="" set "SEVENZIP=%%W"
)
if "%SEVENZIP%"=="" if not "%WINPENPACK_7ZIP%"=="" if exist "%WINPENPACK_7ZIP%" set "SEVENZIP=%WINPENPACK_7ZIP%"

if "%SEVENZIP%"=="" (
    echo [ERRORE] 7-Zip non trovato ^(installazione locale, PATH, o variabile WINPENPACK_7ZIP^).
    echo          Installa 7-Zip, oppure imposta WINPENPACK_7ZIP=percorso\7z.exe
    echo          ^(es. il tuo winPenPack\Bin\7-Zip\7z.exe^) prima di lanciare questo script.
    pause
    exit /b 1
)
echo       Uso 7-Zip: %SEVENZIP%
echo.

:: -------------------------------------------------------------
:: [5/5] Crea lo zip di distribuzione
:: -------------------------------------------------------------
echo [5/5] Creazione dello zip...

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
echo Release creata: %ZIP_FILE%

endlocal
