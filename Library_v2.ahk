#Requires AutoHotkey v2.0

;===============================================================================
; Sleep
;===============================================================================

sleepRandomSeconds(min, max) {
    min *= 1000
    max *= 1000

	sleepTime := Random(minMs, maxMs)
    Sleep(sleepTime)
}


;===============================================================================
; Mouse
;===============================================================================

randomlyMoveMouseTo(x, y, width, height) {
    randX := Random(x, x + width)
    randY := Random(y, y + height)
    
    ; Speed 0 is instant, 2 is default, 100 is slowest
    mouseSpeed := 10 
    MouseMove(randX, randY, mouseSpeed)
    
}


;===============================================================================
; Filesystem
;===============================================================================

IsDirectory(path) {
    ; FileGetAttrib(path) returns a string of attributes (like "RASHNDO")
    ; or throws an Error if the file/folder doesn't exist.
    try {
        attributes := FileGetAttrib(path)
        return InStr(attributes, "D") ? true : false
    } 
	catch {
        return false ; Path doesn't exist
    }
}

exists(path) {
    exists := FileExist(path) ; returns an attribute string for the file or empty if DNE
    if (exists) {
        exists := true
    }
    else {
        exists := false
    }
    
    return exists
    
}


;===============================================================================
; Properties
;===============================================================================

; Returns the value of the given property from ~/.properties.
property(key) {
    home := EnvGet("USERPROFILE")
    propFile := home "\.properties"
    
    if !FileExist(propFile)
        return ""

    Loop read, propFile {
        returnValue := false
        
        ; Parse each line by the "=" delimiter
        Loop parse, A_LoopReadLine, "=" {
            ; Explicitly trim whitespace from the field
            field := Trim(A_LoopField)
            
            if (returnValue) {
                return field
            }
            
            if (field == key) {
                returnValue := true
            }
        } ; loop parse
    } ; loop read
    return ""
}


;===============================================================================
; Numeric
;===============================================================================

; Return the ordinal form of aNumber. 1 => 1st, etc.
ordinal(aNumber) {
    ; Get the last digit and last two digits using SubStr
    ; -1 means "last character", -2 means "last two characters"
    last := SubStr(aNumber, -1)
    lastTwo := (StrLen(aNumber) >= 2) ? SubStr(aNumber, -2) : "0" aNumber

    suffix := "th" ; Default suffix

    ; Handle the "teen" exceptions (11, 12, 13 always end in 'th')
    if (lastTwo != "11" && lastTwo != "12" && lastTwo != "13") {
        ; Switch is much cleaner than a massive if/else chain
        switch last {
            case "1": suffix := "st"
            case "2": suffix := "nd"
            case "3": suffix := "rd"
        }
    }

    ; In v2, := works perfectly for concatenation
    return aNumber suffix
}


;===============================================================================
; Display
;===============================================================================

activeMonitorResolution(&width, &height) {
    ; Set coordinate mode for the mouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mouseX, &mouseY)
    
    ; Get total number of monitors
    monCount := MonitorGetCount()
    
    Loop monCount {
        ; MonitorGet retrieves Left, Top, Right, Bottom 
        ; and stores them in these variables
        MonitorGet(A_Index, &L, &T, &R, &B)
        
        ; Check if mouse is within this monitor's bounds
        if (mouseX >= L && mouseX <= R && mouseY >= T && mouseY <= B) {
            width  := R - L
            height := B - T
            return
        }
    }
}

; Returns the number of the active monitor.
activeMonitor() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    
    ; MonitorGetFromPoint returns the index of the monitor containing the specified coordinates.
    return MonitorGetFromPoint(mx, my)
}

activeMonitorName() {
	host = EnvGet("COMPUTERNAME")
	if (host = "Zenbook") {
		monitorName := "Zenbook"
	}
	return monitorName
}


; Returns the name of the active Google Sheet within a workbook.
activeSheet() {
    CoordMode("Mouse", "Window")
    CoordMode("Pixel", "Window")

    host := EnvGet("COMPUTERNAME")
    monitors := MonitorGetCount()

    activeSheet := "unknown"

    ; ASUS Zenbook 14X OLED
    if (StrLower(host) == "zenbook") {
        ; Update colors for this specific machine
        activeTabColor  := 0xE1E9F7
        activeTabColor2 := 0xE3E9F6

        ; Helper to check color at coordinates
        isActive(x, y) {
            color := PixelGetColor(x, y, "RGB")
            return (color == activeTabColor || color == activeTabColor2)
        }

        ; Check each tab location
        if isActive(400, 1650)
            activeSheet := "Kanban"
        else if isActive(800, 1650)
            activeSheet := "Rocks"
        else if isActive(580, 1650)
            activeSheet := "Recurring"

        ; tabColor := PixelGetColor(580, 1650, "RGB")
        ; MsgBox("Zenbook tab color: " tabColor "`nActive: " activeTabColor, , "T1")
    }

    return activeSheet
}






