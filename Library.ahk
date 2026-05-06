;===============================================================================
; Sleep
;===============================================================================

; converted
sleepRandomSeconds(min, max) {
    min *= 1000
    max *= 1000
    
    Random, sleepTime, min, max
    
    Sleep sleepTime
	
}


;===============================================================================
; Mouse
;===============================================================================

; converted
; Randomly moves to a point within given rectangle. Top left corner is (x, y).
randomlyMoveMouseTo(x, y, width, height) {
    Random, randX , x, x + width
    Random, randY, y, y + height
    
    mouseSpeed := 10 ; 0..100, smaller is faster
    MouseMove, randX, randY, mouseSpeed
    
    ; MsgBox,,, %randX% %randY%
    
}

;===============================================================================
; Filesystem
;===============================================================================


; converted
; Is the given path an existing directory?
isDirectory(path) {
    FileGetAttrib, attributes, %path%
    IfInString, attributes, D
    {
        return true
    }
    
    return false
    
}

; converted
exists(path) {
    exists := FileExist(path) ; returns an attribute string for the file or empty if DNE
    if (exists) {
        exists := true
    }
    else {
        exists := false
    }
    
    return exists
    
} ; exists(path)


;===============================================================================
; Properties
;===============================================================================

; converted
; Returns the value of the given property from ~/.properties.
property(key) {
    EnvGet, home, USERPROFILE
    
    ; Read =-separated fields from each line.
    ; Trim any whitespace from extracted fields.
    Loop, read, %home%\.properties
    {
        Loop, parse, A_LoopReadLine, =
        {
            ; Trimming of spaces happens automatically on assignment.
            field = %A_LoopField%
            if (returnValue == 1) {
                return field
            }
            
            if (field == key) {
                returnValue := 1
            }
            ; MsgBox, Field number %A_Index% is '%field%'.
        }
    }
    ; We didn't find he property.  Return empty string.
    return ""
    
} ; property(key)


;===============================================================================
; Numeric
;===============================================================================

; converted
; Return the ordinal form of a aNumber.  1 => 1st, etc.
ordinal(aNumber) {
    suffix := ""
    ordinal := ""
    
    if (aNumber = 0) {
        suffix := "th"
    }
    else if (aNumber = 1) {
        suffix := "st"
    }
    else if (aNumber = 2) {
        suffix := "nd"
    }
    else if (aNumber = 3) {
        suffix := "rd"
    }
    else if (aNumber = 4) {
        suffix := "th"
    }
    else if (aNumber = 5) {
        suffix := "th"
    }
    else if (aNumber = 6) {
        suffix := "th"
    }
    else if (aNumber = 7) {
        suffix := "th"
    }
    else if (aNumber = 8) {
        suffix := "th"
    }
    else if (aNumber = 9) {
        suffix := "th"
    }
    
    if (aNumber <= 9) {
        ordinal = %aNumber%%suffix%
        return ordinal
    }
    
    ; Get the last two digits of the aNumber.
    StringRight, lastTwo, aNumber, 2 
    StringRight, last, aNumber, 1

    ;MsgBox %lastTwo%

    if (lastTwo >= 21) {        
        if (last = 0) {
            suffix := "th"
        }
        else if (last = 1) {
            suffix := "st"
        }
        else if (last = 2) {
            suffix := "nd"
        }
        else if (last = 3) {
            suffix := "rd"
        }
        else if (last = 4) {
            suffix := "th"
        }
        else if (last = 5) {
            suffix := "th"
        }
        else if (last = 6) {
            suffix := "th"
        }
        else if (last = 7) {
            suffix := "th"
        }
        else if (last = 8) {
            suffix := "th"
        }
        else if (last = 9) {
            suffix := "th"
        }
    }
    else { ; 0 .. 2O 
        ; If aNumber ends in 11, 12, or 13, then the suffix is "th".
        if (lastTwo = "00") {
            suffix := "th"
        }
        else if (lastTwo = "01") {
            suffix := "st"
        }
        else if (lastTwo = "02") {
            suffix := "nd"
        }
        else if (lastTwo = "03") {
            suffix := "rd"
        }
        else if (lastTwo = "04") {
            suffix := "th"
        }
        else if (lastTwo = "05") {
            suffix := "th"
        }
        else if (lastTwo = "06") {
            suffix := "th"
        }
        else if (lastTwo = "07") {
            suffix := "th"
        }
        else if (lastTwo = "08") {
            suffix := "th"
        }
        else if (lastTwo = "09") {
            suffix := "th"
        }
        else if (lastTwo = "10") {
            suffix := "th"
        }
        else if (lastTwo = "11") {
            suffix := "th"
        }
        else if (lastTwo = "12") {
            suffix := "th"
        }
        else if (lastTwo = "13") {
            suffix := "th"
        }
        else if (lastTwo = "14") {
            suffix := "th"
        }
        else if (lastTwo = "15") {
            suffix := "th"
        }
        else if (lastTwo = "16") {
            suffix := "th"
        }
        else if (lastTwo = "17") {
            suffix := "th"
        }
        else if (lastTwo = "18") {
            suffix := "th"
        }
        else if (lastTwo = "19") {
            suffix := "th"
        }
        else if (lastTwo = "20") {
            suffix := "th"
        }
        
    } ; else
    
    ordinal = %aNumber%%suffix% ; using := doesn't work here
    ;MsgBox %ordinal%
    return ordinal
    
} ; ordinal(aNumber)


;===============================================================================
; Display
;===============================================================================

; converted
activeMonitorResolution(ByRef width, ByRef height) {
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX , mouseY
	SysGet, monCount, MonitorCount
	Loop %monCount%
    { 	
		SysGet, curMon, Monitor, %A_Index%
        if (mouseX >= curMonLeft and mouseX <= curMonRight and mouseY >= curMonTop and mouseY <= curMonBottom) {
			; X      := curMonTop
			; y      := curMonLeft
			height := curMonBottom - curMonTop
			width  := curMonRight  - curMonLeft
			return
		}
    } ; next monitor
} ; activeMonitorResolution()


; converted
; Returns the number of the active monitor.
; This is the number assigned in Windows' display setup.
activeMonitor() {
	; get the mouse coordinates first
	CoordMode, Mouse, Screen ; use Screen, so we can compare the coords with the SysGet info.
	MouseGetPos, mx, my

	; This doesn't match up with the number Windows assigns each monitor.
	; Maybe it would work if the monitors were all in a single row.
	SysGet, monitorCount, 80 ; Get total number of monitors.
	Loop, %monitorCount%
	{
		SysGet, mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars

		if ( mx >= mon%A_Index%left ) && ( mx < mon%A_Index%right ) && ( my >= mon%A_Index%top ) && ( my < mon%A_Index%bottom ) {
			monitor := A_Index
			break
		}
	} ; next monitor
	return monitor

} ; activeMonitor()


; converted
activeMonitorName() {
	EnvGet, host, COMPUTERNAME
	if (host = "Zenbook") {
		monitorName := "Zenbook"
	}
	return monitorName
} ; activeMonitorName()


; converted
; Returns the name of the active Google Sheet within a workbook.
activeSheet() {
	CoordMode, Mouse, Window
	CoordMode, Pixel, Window
	EnvGet, host, COMPUTERNAME
	SysGet, monitors, MonitorCount
	activeSheet := "Unknown"
	tabColor := 0 ; a sample pixel from the first Google Sheets sheet tab
	activeMonitor := activeMonitorName()
	oldActiveTabColor := 0xFFFFFF ; pixel color when first Google Sheet tab is active
	; activeTabColor := 0xDAE5F9 ; this is the color it is when mouse is hovering 
	activeTabColor := 0xE2E9F8
	activeTabColor2 := 0xE1E9F7

	if ((host = "Zenbook") or (host = "ZENBOOK")) { ; ASUS Zenbook 14X OLED
		; activeTabColor := 0xDCE5F6
		; Not sure if night light mode is changing the reported color or something else.
		activeTabColor2 := 0xE3E9F6
		activeTabColor := 0xE1E9F7
		PixelGetColor, tabColor, 400, 1650, RGB
		if ((tabColor = activeTabColor) or (tabcolor = activeTabColor2)) {
			 activeSheet := "Kanban"
		}
		PixelGetColor, tabColor, 800, 1650, RGB
		if ((tabColor = activeTabColor) or (tabColor = activeTabColor2)) {
			activeSheet := "Rocks"
		}
		PixelGetColor, tabColor, 580, 1650, RGB
		; MsgBox,,, Zenbook tab color: %tabColor% 
		; MsgBox,,, Zenbook active tab color: %activeTabColor%
		if ((tabColor = activeTabColor) or (tabColor = activeTabColor2)) {
			activeSheet := "Recurring"
		}
	}
	
	; MsgBox,,, %activeSheet%
	return activeSheet
} ; activeSheet()


