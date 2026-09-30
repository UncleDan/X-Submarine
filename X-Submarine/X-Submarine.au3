;   winPenPack X-Submarine Launcher
;   by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0b9 - 2026-09-29 14:05:00
;   Basato sul codice sorgente generico di X-Launcher 1.5.4 (winPenPack),
;   con solo icona e informazioni di risorsa personalizzate per Submarine.

#Region

;** AUT2EXE settings
#AutoIt3Wrapper_Outfile=X-Submarine.exe
#AutoIt3Wrapper_Outfile_Type=exe
#AutoIt3Wrapper_Icon=graphics\x-icon.ico
#AutoIt3Wrapper_Compression=2
#AutoIt3Wrapper_UseUpx=N

;** AUTOIT3 settings
#AutoIt3Wrapper_UseAnsi=Y
#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Version=P
#AutoIt3Wrapper_Run_Debug_Mode=N

;** Target program Resource info
#AutoIt3Wrapper_Res_Field=ProductName|winPenPack X-Submarine
#AutoIt3Wrapper_Res_Field=ProductVersion|1.0b9
#AutoIt3Wrapper_Res_Field=OriginalFilename|X-Submarine.exe
#AutoIt3Wrapper_Res_Field=InternalName|X-Submarine
#AutoIt3Wrapper_Res_Description=winPenPack X-Submarine Launcher
#AutoIt3Wrapper_Res_Field=CompanyName|www.winpenpack.com
#AutoIt3Wrapper_Res_Field=Authors|Daniele Lolli (UncleDan)
#AutoIt3Wrapper_Res_Fileversion=1.0.0.9
#AutoIt3Wrapper_Res_Comment=X-Launcher allows you to change at will the options for initiating programs undertaken in order to make them portable.
#AutoIt3Wrapper_Res_LegalCopyright=GNU General Public License
#AutoIt3Wrapper_Res_Field=LegalTrademarks|winPenPack
#AutoIt3Wrapper_Res_Language=1040
#AutoIt3Wrapper_Res_RequestedExecutionLevel=None

#EndRegion

;** Include X-Launcher's source code (tutto nella stessa cartella, layout
;   flat come nel pacchetto sorgente generico X-Launcher 1.5.4 — nessuna
;   sottocartella "_x-launcher" separata)
#include 'x-launcher.au3'
#include 'files\x-install.au3'
