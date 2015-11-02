#Include %A_ScriptDir%\Library.ahk

#NoTrayIcon

; Assumes ShortKeys is already running.
; Assumes ShortKeys has <Ctrl + Alt + S> set to toggle enabled/disabed status.

; If enabled, disables ShortKeys.
; If disabled already, does nothing.

; I intend to trigger this script as an autocommand in vim when it exits insert mode.

if ( ShortKeysIsRunning() ) {
	if ( ShortKeysIsEnabled() ) {
		; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being enabled/disabled.
		Send ^!s
	}
	else { ; Already disabled: do nothing.
		; Do nothing.
	}
}
else { ; ShortKeys is not running.
	; Not running achieves the same result as being disabled.
} ; else

