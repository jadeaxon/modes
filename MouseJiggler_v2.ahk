#Requires AutoHotkey v2.0

; Automatically move mouse if connected to multiple monitors.
; They want to sleep to fast and don't always come back properly.

; Set the Tray Icon
TraySetIcon("Icons\MouseJiggler.ico")

CoordMode("Mouse", "Window")

lastX := 0
lastY := 0
x := 0
y := 0

; Infinite loop for the jiggler
Loop {
	MouseGetPos(&x, &y)

	; If the mouse hasn't moved since the last check
	if (x = lastX && y = lastY) {
		; Move the mouse 5 pixels diagonally
		MouseMove(x + Random(-5, 5), y + Random(-5, 5))
	}

	; Update the last known position
	MouseGetPos(&lastX, &lastY)

	; Wait 20 seconds.
	Sleep(20 * 1000)
}



