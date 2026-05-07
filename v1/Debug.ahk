; Hotkeys for helping to debug AHK scripts.

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt

;=============================================================================== 
; MAIN
;===============================================================================

; NOTE: You must *not* put any hotkey definitions before here or this won't execute.

Menu, Tray, Icon, Icons\Debug.ico

; Use mouse coordinates relative to the active window.
CoordMode, Mouse, Relative


;=============================================================================== 
; HOTKEYS
;=============================================================================== 


;-------------------------------------------------------------------------------
; This gives you details on what keystrokes have been pressed recently.
; Including scan codes and virtual key numbers.
k::
	; Send, {Enter}
	; Sleep 1000
	KeyHistory
return

;------------------------------------------------------------------------------- 
; Report mouse position.
p::
	MouseGetPos, xpos, ypos 
	Msgbox, The mouse is at relative coordinate (%xpos%, %ypos%). 
Return


;-------------------------------------------------------------------------------
; Open AHK help docs for the word under the mouse.
h::	
    Click
	Click
	Send, ^c
	Sleep 10
	
	Run C:\Program Files\AutoHotkey\AutoHotkey.chm
	WinWait, AutoHotkey Help
	Send, !n ; Select the index tab.
	Sleep 10
    Suspend On ; Else the clipboard contents will triggered when sent!
	Send, %clipboard%
	Suspend Off
	Sleep 10
	Send, {Enter}
	
return


;------------------------------------------------------------------------------- 
; Terminate this keystroke handler.  End this context.
LControl & Escape::
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Sounds\Debug_Exit.wav, Wait
ExitApp

