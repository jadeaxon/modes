Menu, Tray, Icon, %A_ScriptDir%\Icons\Path of Exile.ico
CoordMode, Mouse, Relative

openTownPortal() {
	BlockInput On
	; Open inventory.
	Send c
	; Sleep 1000
	; Click town portal scroll (in upper left corner of inventory).
	x := 920
	y := 420
	; MouseMove x, y
	; Sleep 1000
	Sleep 100
	MouseMove x, y
	Click right x, y
	; Close inventory.
	Sleep 100
	Send c
	BlockInput Off
}

; Cause home key to trigger opening of town portal.
$]::
	openTownPortal()
return

