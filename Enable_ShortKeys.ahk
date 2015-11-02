#Include %A_ScriptDir%\Library.ahk

#NoTrayIcon

; Assumes ShortKeys is already running.
; Assumes ShortKeys has <Ctrl + Alt + S> set to toggle enabled/disabed status.

; If disabled, enables ShortKeys.
; If enabled already, does nothing.

; I intend to trigger this script as an autocommand in vim when it enters insert mode.
; You really only want all the abbreviation expansions active in insert mode.
; I don't want to have to load them all as :iabbrev commands in vim itself.  Redundant.

if ( ShortKeysIsRunning() ) {
	if ( ShortKeysIsEnabled() ) {
		; Do nothing.
		
	}
	else { ; Disabled.
		; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being enabled/disabled.
		Send ^!s
	}
}
else { ; ShortKeys is not running.
	; TODO: We could try to start ShortKeys here.
	
} ; else

