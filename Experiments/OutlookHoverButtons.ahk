#Warn

hoveredControl := ""
window := ""
x := 0
y := 0

SetTimer, showHoverButtons, 1000
return

showHoverButtons:
	CoordMode, Mouse, Screen
	MouseGetPos, x, y, window, hoveredControl
	; Yes, this will be OutlookGrid2.

	; The default Gui title is the name of the script.
	if (not WinActive("OutlookButtons.ahk")) {
		Gui, Destroy ; Only destroys if exists.
	}

	if (hoveredControl == "OutlookGrid2") {
		Gui, Destroy
		; MsgBox, %hoveredControl%
		; return
		
		Gui, -border
		Gui, Add, Button, gDeleteEmail w20 h20, D
		Gui, Add, Button, gArchiveEmail yp x+5 w20 h20, A
		
		; The GUI will be the last remembered window.
		; Set its top corner to the mouse location.
		Gui, Show, x%x% y%y%
		; WinMove, %x%, %y%
	}

return

; Gets rid of the hover buttons, clicks on the message below it, and deletes it.
deleteEmail:
	Gui, Destroy
	Sleep 20
	Click
	Send ^q ; Mark as read.
	Send {delete}
return


archiveEmail:
	Gui, Destroy
	Sleep 20
	Click
return




