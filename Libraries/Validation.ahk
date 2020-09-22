;==============================================================================
; Tests
;==============================================================================

; How do we only run this test section if script is run rather than included?
Run, Notepad.exe
Sleep, 500
WinActivate, Notepad
; WinMaximize, Notepad
; WinWaitActive, Notepad
Sleep, 500

Send, #{Up}
Send, Testing Validation.ahk{enter}
Send, % isValidNumber("foo") . "`n"
Send, % isValidNumber("-15.72") . "`n"
return


;==============================================================================
; Validation Functions
;==============================================================================

; Validates a number.
isValidNumber(alleged) {
	count := 0
	pos := RegExMatch(alleged, "^-?[\d.]+") ; Only leading -, digits, and decimal points.
	RegExReplace(alleged, "[.]", "", count) ; At most one decimal point.
	if ((pos > 0) && (count <= 1)) {
		return true
	}
	return false
}


