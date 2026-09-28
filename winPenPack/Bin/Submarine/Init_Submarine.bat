@echo off
:: Init_Submarine.bat by Daniele Lolli (UncleDan) feat. Claude AI - Release 2.0 - 2026-09-27 16:09:04
setlocal enabledelayedexpansion
title Download Submarine Portable

:: Siccome il batch si trova in Bin\Submarine, impostiamo la directory corrente
set "APP_DIR=%~dp0"
:: Rimuove il backslash finale per prevenire problemi di escaping durante l'estrazione
if "%APP_DIR:~-1%"=="\" set "APP_DIR=%APP_DIR:~0,-1%"

set "SETUP_FILE=%APP_DIR%\Submarine_setup.exe"
set "CHECKSUM_FILE=%APP_DIR%\Submarine_setup.sha256"

echo =======================================================
echo     Scaricamento Submarine in corso...
echo =======================================================
echo.

:: -------------------------------------------------------------
:: [1/5] Ricerca dell'ultima release su GitHub API (arch x64/arm64)
:: -------------------------------------------------------------
echo [1/5] Ricerca dell'ultima release su GitHub API...

set "ARCH_PATTERN=x64-setup"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH_PATTERN=arm64-setup"

set "DOWNLOAD_URL="
set "CHECKSUM_URL="
for /f "delims=" %%A in ('powershell -NoProfile -Command ^
    "$r = Invoke-RestMethod -Uri 'https://api.github.com/repos/SinaXhpm/Submarine/releases/latest';" ^
    "$asset = $r.assets | Where-Object { $_.name -match '%ARCH_PATTERN%\.exe$' } | Select-Object -First 1;" ^
    "$sum = $r.assets | Where-Object { $_.name -match '(%ARCH_PATTERN%\.exe\.sha256$|checksums?\.txt$|SHA256SUMS$)' } | Select-Object -First 1;" ^
    "Write-Output ($asset.browser_download_url);" ^
    "Write-Output ($sum.browser_download_url)"
') do (
    if not defined DOWNLOAD_URL (set "DOWNLOAD_URL=%%A") else if not defined CHECKSUM_URL (set "CHECKSUM_URL=%%A")
)

if "%DOWNLOAD_URL%"=="" (
    echo [ERRORE] Impossibile trovare il link per il download ^(architettura: %ARCH_PATTERN%^).
    pause
    exit /b 1
)

:: -------------------------------------------------------------
:: [2/5] Download del setup, con un tentativo di retry
:: -------------------------------------------------------------
echo [2/5] Download in corso da GitHub...
if exist "%SETUP_FILE%" del /q "%SETUP_FILE%"
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%SETUP_FILE%' } catch { exit 1 }"

if not exist "%SETUP_FILE%" (
    echo       Primo tentativo fallito, ritento tra 3 secondi...
    ping 127.0.0.1 -n 4 > nul
    powershell -NoProfile -Command "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%SETUP_FILE%' } catch { exit 1 }"
)

if not exist "%SETUP_FILE%" (
    echo [ERRORE] Download fallito dopo 2 tentativi.
    pause
    exit /b 1
)

:: -------------------------------------------------------------
:: [3/5] Verifica checksum, se pubblicato dalla release
:: -------------------------------------------------------------
echo [3/5] Verifica integrita' del file scaricato...
if not "%CHECKSUM_URL%"=="" (
    powershell -NoProfile -Command "Invoke-WebRequest -Uri '%CHECKSUM_URL%' -OutFile '%CHECKSUM_FILE%'" >nul 2>&1
)

if exist "%CHECKSUM_FILE%" (
    for /f "delims=" %%H in ('certutil -hashfile "%SETUP_FILE%" SHA256 ^| findstr /v "hash CertUtil"') do set "ACTUAL_HASH=%%H"
    set "ACTUAL_HASH=!ACTUAL_HASH: =!"
    findstr /i /c:"!ACTUAL_HASH!" "%CHECKSUM_FILE%" >nul
    if errorlevel 1 (
        echo [ERRORE] Il checksum del file scaricato non corrisponde. Download interrotto per sicurezza.
        del /q "%SETUP_FILE%" "%CHECKSUM_FILE%" >nul 2>&1
        pause
        exit /b 1
    ) else (
        echo       Checksum verificato correttamente.
    )
    del /q "%CHECKSUM_FILE%" >nul 2>&1
) else (
    echo       [ATTENZIONE] Nessun checksum pubblicato dalla release: verifica saltata.
)

:: -------------------------------------------------------------
:: [4/5] Ricerca di 7-Zip: prima installazione locale, poi winPenPack
:: -------------------------------------------------------------
echo [4/5] Ricerca di 7-Zip per l'estrazione...
set "SEVENZIP="

if exist "C:\Program Files\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if "%SEVENZIP%"=="" if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"

if "%SEVENZIP%"=="" (
    :: Nessuna installazione locale: cerco il 7-Zip portabile di winPenPack
    :: Struttura: winPenPack\Bin\7-Zip\7z.exe (stesso livello di Bin\Submarine)
    if exist "%APP_DIR%\..\7-Zip\7z.exe" set "SEVENZIP=%APP_DIR%\..\7-Zip\7z.exe"
)

if "%SEVENZIP%"=="" (
    echo [ERRORE] 7-Zip non trovato ne' come installazione locale ne' come app winPenPack.
    pause
    exit /b 1
)
echo       Uso 7-Zip: %SEVENZIP%

:: -------------------------------------------------------------
:: [5/5] Estrazione e pulizia post-estrazione NSIS
:: -------------------------------------------------------------
echo [5/5] Estrazione in corso...
"%SEVENZIP%" x "%SETUP_FILE%" -o"%APP_DIR%" -y > nul

:: Isola l'eseguibile Tauri dalla struttura dell'installer NSIS
if exist "%APP_DIR%\$_OUTDIR\Submarine.exe" (
    xcopy "%APP_DIR%\$_OUTDIR\*" "%APP_DIR%\" /s /e /y > nul
    rmdir /s /q "%APP_DIR%\$_OUTDIR"
)
if exist "%APP_DIR%\$PLUGINSDIR" rmdir /s /q "%APP_DIR%\$PLUGINSDIR"
if exist "%APP_DIR%\$TEMP" rmdir /s /q "%APP_DIR%\$TEMP"

if exist "%SETUP_FILE%" del "%SETUP_FILE%"

if not exist "%APP_DIR%\Submarine.exe" (
    echo [ERRORE] Estrazione completata ma Submarine.exe non e' stato trovato.
    pause
    exit /b 1
)

echo.
echo Download ed estrazione completati! Avvio di Submarine...
ping 127.0.0.1 -n 3 > nul

endlocal
