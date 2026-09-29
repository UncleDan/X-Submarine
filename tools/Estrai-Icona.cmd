@echo off
:: Estrai-Icona.cmd by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0b9 - 2026-09-29 13:37:52
setlocal enabledelayedexpansion

set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

set "SUBMARINE_EXE=%ROOT%\Bin\Submarine\Submarine.exe"
set "ICON_OUT=%ROOT%\X-Submarine\graphics\x-icon.ico"
set "PLACEHOLDER_MARKER=%ROOT%\X-Submarine\graphics\.icon-is-placeholder"

:: Il pacchetto include gia' un'icona segnaposto generica (x-icon.ico),
:: cosi' la compilazione funziona anche al primo giro. Questo script la
:: sostituisce con l'icona vera di Submarine SOLO se:
::  - Submarine.exe e' gia' stato scaricato in Bin\Submarine\, E
::  - l'icona attuale e' ancora quella segnaposto (marker presente) —
::    se l'hai gia' sostituita a mano con una tua icona, non la tocca.

if not exist "%PLACEHOLDER_MARKER%" (
    :: Icona gia' personalizzata dall'utente: non toccarla
    exit /b 0
)

if not exist "%SUBMARINE_EXE%" (
    echo [INFO] Uso ancora l'icona segnaposto: Submarine.exe non e' ancora
    echo        stato scaricato in Bin\Submarine\. Eseguilo una volta
    echo        ^(Bin\Submarine\Init_Submarine.bat^) poi rilancia questa build
    echo        per usare l'icona vera di Submarine.
    exit /b 0
)

echo [INFO] Submarine.exe trovato: estraggo la sua icona...
powershell -NoProfile -Command ^
    "try {" ^
    "  Add-Type -AssemblyName System.Drawing;" ^
    "  $ico = [System.Drawing.Icon]::ExtractAssociatedIcon('%SUBMARINE_EXE%');" ^
    "  $fs = New-Object System.IO.FileStream('%ICON_OUT%', [System.IO.FileMode]::Create);" ^
    "  $ico.Save($fs); $fs.Close();" ^
    "} catch { exit 1 }"

if errorlevel 1 (
    echo [ATTENZIONE] Estrazione fallita: continuo con l'icona segnaposto.
    exit /b 0
)

del /q "%PLACEHOLDER_MARKER%" >nul 2>&1

echo       Icona di Submarine estratta in graphics\x-icon.ico
echo       ^(nota: e' una singola risoluzione presa dall'icona associata
echo       a Submarine.exe, non un .ico multi-risoluzione professionale.
echo       Se vuoi un risultato migliore, sostituiscila con un'icona
echo       ufficiale del progetto, es. da src-tauri\icons\icon.ico nel
echo       repository GitHub di Submarine — in tal caso cancella anche
echo       il file graphics\.icon-is-placeholder se ancora presente.^)

endlocal
exit /b 0
