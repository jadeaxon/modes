#Include %A_ScriptDir%\Library.ahk

value := property("name.first")
MsgBox,,, %value%

ExitApp

; Loop through all windows.
WinGet window_list, List 
Loop %window_list% {
	window_id := window_list%A_Index%
	WinGetTitle window_title, ahk_id %window_id%
	MsgBox,,, %window_id%`n%window_title%
	
	; TODO: Turn this into a function and then trigger it from a timer loop in Master.ahk.
	
	; Maximize the Pidgin conversation window.
	; if InStr(title, "Pidgin") {
	; 	WinMaximize
	; }
} ; next window


; The other (probably better) option is to remap <Window + M> to do the normal action and the maximize Pidgin conversation.
