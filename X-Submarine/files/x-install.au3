; ------------------------------------------------------------------------------
;
;					X-install
;
; ------------------------------------------------------------------------------
;
;===============================================================================
;
; Function Name:	_DefaultInstal()
; Description:		Install base default files (nessuno per Submarine)
; Syntax:			_DefaultInstal(Tempdir, lang)
;
;===============================================================================
Func _DefaultInstall($Temp, $Lang="it")

	; Submarine non ha file di default da installare (nessun profilo utente
	; incorporato nel launcher): la funzione deve esistere perche' richiamata
	; dal motore generico, ma qui non fa nulla.

EndFunc   ;==>_DefaultInstal
