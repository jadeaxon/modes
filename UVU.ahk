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
$t::
	WinActivate Enter Payment Information
	WinWaitActive Enter Payment Information
	Send ^l
	Send {Tab}{Tab} ; Credit Card Type.
	Send {Down}{Down}{Down}{Down} ; Select Visa.
	Send {Tab} ; Account number.
	Send 4111111111111111 ; Fake credit card.
	Sleep 100
	Send {Tab} ; Expiration date month.
	Send {Down} ; Expire next month.
	Send {Tab} ; Expiration date year.
	Sleep 100
	Send {Tab} ; View example link.
	Send {Tab} ; Security code.  
	Send 125 ; Fake CCV.
	Send {Tab} ; Name on card.
	Sleep 100
	Send {Tab} ; Address line 1.
	Send 777 Lucky Lane
	Send {Tab} ; Address line 2.
	Sleep 100
	Send {Tab} ; City.
	Sleep 100
	Send Provo
	Send {Tab} ; State.
	Sleep 100
	Send U ; Utah.
	Sleep 100
	Send {Tab} ; Zip code.
	Sleep 100
	Send 84601
	Send {Tab} ; Country.
	Sleep 100
	Send {Tab} ; E-mail.
	Send jadeaxon@hotmail.com
	Send {Tab} ; Day phone.
	Sleep 100
	Send {Tab} ; Mobile phone.
	Sleep 100
	Send {Tab} ; Continue button.

return



; Terminate this keystroke handler.  End this context.
LControl & Escape::
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Sounds\Debug_Exit.wav, Wait
ExitApp

