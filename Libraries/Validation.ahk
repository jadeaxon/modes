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
Send, % isValidIPAddress("no way") . "`n"
Send, % isValidIPAddress("127.0.0.1") . "`n"
Send, % isValidIPAddress("256.256.256.256") . "`n"
Send, % isValidEmailAddress("person@somewhere.tld") . "`n"
Send, % isValidEmailAddress("not a valid email address") . "`n"
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


; Validates an IP address.
isValidIPAddress(alleged) {
	regex := "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
	pos := RegExMatch(alleged, regex)
	return (pos > 0) ? true : false
}


; Validates an email address.
isValidEmailAddress(alleged) {
	regex := "^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,4})+$"
	pos := RegExMatch(alleged, regex)
	return (pos > 0) ? true : false
}




