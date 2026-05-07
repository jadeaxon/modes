#Persistent

;==============================================================================
; Autoexec
;==============================================================================

; Update tooltip for whatever window the mouse cursor is hovering over every second.
Toggle := true
SetTimer, WatchCursor, 2000
return


;==============================================================================
; Subroutines, Hotkeys, etc.
;==============================================================================

; Update tooltip for whatever window the mouse cursor is hovering over.
WatchCursor:
	MouseGetPos,,, id, control
	WinGetTitle, title, ahk_id %id%
	WinGetClass, class, ahk_id %id%
	ControlGetFocus, ActiveWin, A
	WinGetText, text, ahk_id %id%

	vWindowInfo = 
	( LTrim
		Unique ID: ahk_id %id%
		Title: %title%
		Class: ahk_class %class%
		Control: %control%
		Active Control: %ActiveWin%
		Text: %text%

		<C-W t> Toggle this tooltip.
		<C F12> Copy info to clipboard.
		<C Esc> Exit.
	)
	ToolTip, %vWindowInfo% 
return


; Toggle display of the tooltip.
$^#t:: 
	SetTimer, WatchCursor, % (Toggle := !Toggle) ? "On" : "Off"
	if (Toggle = false) {
		Tooltip
	}
return


; Copy the tooltip to the clipboard.
$^F12::
	Clipboard := vWindowInfo
return

$^Esc::ExitApp



