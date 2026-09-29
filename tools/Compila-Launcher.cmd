@echo off
:: Compila-Launcher.cmd by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0 - 2026-09-29 08:32:19
setlocal enabledelayedexpansion
title Compilazione X-Submarine

:: Cartella del progetto (un livello sopra tools\)
set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

set "AU3_SOURCE=%ROOT%\_launcher-source\X-Submarine\X-Submarine.au3"
set "AU3_OUT=%ROOT%\_launcher-source\X-Submarine\X-Submarine.exe"

echo =======================================================
echo     Compilazione X-Submarine.exe
echo =======================================================
echo.

if not exist "%AU3_SOURCE%" (
    echo [ERRORE] Non trovo %AU3_SOURCE%
    pause
    exit /b 1
)

:: Se manca un'icona personalizzata, prova a estrarla da Submarine.exe
:: (se gia' scaricato in Bin\Submarine\); altrimenti non fa nulla e si
:: compila con l'icona di default di AutoIt.
call "%~dp0Estrai-Icona.cmd"
echo.

:: -------------------------------------------------------------
:: Ricerca di AutoIt3Wrapper.exe ^(preferito: legge le direttive
:: #AutoIt3Wrapper_* incorporate nel .au3 - icona, versione, ecc.^)
:: Ordine: percorsi standard, PATH, infine WINPENPACK_AUTOIT_DIR
:: ^(variabile d'ambiente opzionale con la cartella di installazione
:: di AutoIt, es. D:\Portable\AutoIt3^).
:: -------------------------------------------------------------
set "WRAPPER="
for %%P in (
    "%ProgramFiles(x86)%\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe"
    "%ProgramFiles%\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe"
) do (
    if "%WRAPPER%"=="" if exist %%P set "WRAPPER=%%~P"
)
if "%WRAPPER%"=="" (
    for /f "delims=" %%W in ('where AutoIt3Wrapper.exe 2^>nul') do if "%WRAPPER%"=="" set "WRAPPER=%%W"
)
if "%WRAPPER%"=="" if not "%WINPENPACK_AUTOIT_DIR%"=="" (
    if exist "%WINPENPACK_AUTOIT_DIR%\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe" set "WRAPPER=%WINPENPACK_AUTOIT_DIR%\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe"
)

if not "%WRAPPER%"=="" (
    echo Uso AutoIt3Wrapper: %WRAPPER%
    echo.
    "%WRAPPER%" /in "%AU3_SOURCE%" /prod
    if errorlevel 1 (
        echo [ERRORE] Compilazione fallita.
        pause
        exit /b 1
    )
    goto :verifica
)

:: -------------------------------------------------------------
:: Fallback: Aut2exe.exe diretto ^(le direttive #AutoIt3Wrapper_*
:: nel .au3 NON vengono lette: icona/versione vanno passate a mano^)
:: Stesso ordine: percorsi standard, PATH, WINPENPACK_AUTOIT_DIR.
:: -------------------------------------------------------------
echo [ATTENZIONE] AutoIt3Wrapper.exe non trovato, uso Aut2exe.exe come fallback.
echo              Icona e informazioni di versione potrebbero non essere applicate.
echo.

set "AUT2EXE="
for %%P in (
    "%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe"
    "%ProgramFiles%\AutoIt3\Aut2Exe\Aut2exe.exe"
    "C:\X-Software\A\winPenPack\Bin\autoit-v3\install\Aut2Exe\Aut2exe.exe"
) do (
    if "%AUT2EXE%"=="" if exist %%P set "AUT2EXE=%%~P"
)
if "%AUT2EXE%"=="" (
    for /f "delims=" %%W in ('where Aut2exe.exe 2^>nul') do if "%AUT2EXE%"=="" set "AUT2EXE=%%W"
)
if "%AUT2EXE%"=="" if not "%WINPENPACK_AUTOIT_DIR%"=="" (
    if exist "%WINPENPACK_AUTOIT_DIR%\Aut2Exe\Aut2exe.exe" set "AUT2EXE=%WINPENPACK_AUTOIT_DIR%\Aut2Exe\Aut2exe.exe"
)

if "%AUT2EXE%"=="" (
    echo [ERRORE] Ne' AutoIt3Wrapper.exe ne' Aut2exe.exe sono stati trovati.
    echo          Installa AutoIt da https://www.autoitscript.com/, imposta
    echo          WINPENPACK_AUTOIT_DIR sulla cartella di installazione, oppure
    echo          apri X-Submarine.au3 in SciTE e compila con Ctrl+F7.
    pause
    exit /b 1
)

set "ICON_ARG="
if exist "%ROOT%\_launcher-source\X-Submarine\graphics\x-icon.ico" set "ICON_ARG=/icon "%ROOT%\_launcher-source\X-Submarine\graphics\x-icon.ico""

"%AUT2EXE%" /in "%AU3_SOURCE%" /out "%AU3_OUT%" %ICON_ARG% /comp 2
if errorlevel 1 (
    echo [ERRORE] Compilazione fallita.
    pause
    exit /b 1
)

:verifica
if not exist "%AU3_OUT%" (
    echo [ERRORE] Compilazione terminata ma X-Submarine.exe non e' stato trovato.
    pause
    exit /b 1
)

echo.
echo Compilazione completata: %AU3_OUT%

endlocal
