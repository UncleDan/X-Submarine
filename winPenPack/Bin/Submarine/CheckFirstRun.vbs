' CheckFirstRun.vbs by Daniele Lolli (UncleDan) feat. Claude AI - Release 1.0 - 2026-09-27 16:09:04

Set fso = CreateObject("Scripting.FileSystemObject")
Dim scriptDir, exePath, batPath

' La cartella di esecuzione e' gia' Bin\Submarine
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
exePath = fso.BuildPath(scriptDir, "Submarine.exe")
batPath = fso.BuildPath(scriptDir, "Init_Submarine.bat")

' Avvia il batch di download SOLO se l'eseguibile manca
If Not fso.FileExists(exePath) Then
    Dim shell
    Set shell = CreateObject("WScript.Shell")
    ' 1 = Finestra visibile, True = Mette X-Launcher in attesa
    shell.Run """" & batPath & """", 1, True
End If
