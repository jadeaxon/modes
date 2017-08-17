; Reload Master.ahk from Cygwin.
; PRE: <C Esc> does not use the keyboard hook (#UseHook off).
; PRE: Firefox is running.  For me, this is essentially always true.
; PRE: Running from Cygwin using my override of . in Bash to call this script.

; Without this, hotkeys in other scripts won't trigger.
; In that case, sending <C Esc> just makes the Windows start menu pop up.
SendLevel 1 

; When the Cygwin window is active, it swallows all keystrokes directly.
; Thus, hotkeys defined in Master.ahk cannot be activated in that context.
WinActivate ahk_class MozillaWindowClass
WinWaitActive ahk_class MozillaWindowClass

Send {LControl down}{Esc down} ; Now the Master.ahk reload hotkey will work.
; Sleep 100
Send {Esc up}{LControl up}

; Hmmm.  Bash shows this as exiting with value 1.  Not sure why.
ExitApp 0

