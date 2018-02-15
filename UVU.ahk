; Hotkeys for doing UVU-specific tasks.

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt

;=============================================================================== 
; Main
;===============================================================================

; NOTE: You must *not* put any hotkey definitions before here or this won't execute.

Menu, Tray, Icon, Icons\UVU.ico

; Use mouse coordinates relative to the active window.
CoordMode, Mouse, Relative


;=============================================================================== 
; Hotkeys
;=============================================================================== 


; Fill in the TouchNet payment form in QA.
t::
	Send {Down}
return




; Terminate this keystroke handler.  End this context.
LControl & Escape::
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Sounds\Debug_Exit.wav, Wait
ExitApp

