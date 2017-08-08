; Launches Weather Windows app only between 4 AM and 11 AM.
; I put a shortcut to this AHK in my Windows startup folder.
; <W r>shell:common startup
FormatTime, hour, H, H ; Get 0-23 hour with no leading zero.

hour += 0 ; Convert string to int?  Seems to.
; MsgBox %hour%
If ((hour >= 4) && (hour <= 11))
{
	; This being a Windows built-in app, it's not clear how to call it directly.
	; So, we use a link to it.
	Run Weather.lnk
}


