#Requires AutoHotkey v2.0

; Reload Master.ahk from Cygwin.
; PRE: <C Esc> does not use the keyboard hook (#UseHook off).
; PRE: Running from Cygwin using my override of . in Bash to call this script.

; Level 1 allows sent keys to trigger other scripts' hotkeys.
; Without this, hotkeys in other scripts won't trigger.
; In that case, sending <C Esc> just makes the Windows start menu pop up.
SendLevel(1)
SendEvent("{LControl down}{Esc down}")
SendEvent("{Esc up}{LControl up}")
ExitApp(0)

