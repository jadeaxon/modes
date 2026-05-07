; Automatically move mouse if connected to multiple monitors.
; They want to sleep to fast and don't always come back properly.

; Warn about using uninitialized variables.
#Warn

; Do not automatically load environment variables.
#NoEnv

; Persistent scripts keep running forever until explicitly closed.
#Persistent

; Only allow one instance of this script to run at a time.
#SingleInstance Force

Menu, Tray, Icon, %A_ScriptDir%\Icons\MouseJiggler.ico

CoordMode, Mouse, Relative

lastX := 0
lastY := 0
x := 0
y := 0
monitorCount := 0

while (true) {
	SysGet, monitorCount, 80 ; Get total number of monitors.
	if (monitorCount > 1) {
		MouseGetPos, x, y
		if ((x = lastX) and (y = lastY)) {
			MouseMove, % x+5, % y+5
		}
		MouseGetPos, lastX, lastY
		Sleep, 60000 ; 1 minute
	}
}

