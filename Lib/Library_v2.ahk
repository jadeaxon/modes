#Requires AutoHotkey v2.0

HOME := EnvGet("USERPROFILE")
HOST := EnvGet("COMPUTERNAME")
delay := 30
;vUserProfile := EnvGet("USERPROFILE")


;===============================================================================
; String
;===============================================================================

; Removes all invisible control characters and strips ALL types of 
; whitespace (including non-breaking spaces) from both ends.
; WARNING: You can get such possessed strings when you read from the clipboard.
Exorcise(s) {
    ; 1. Remove Control Characters (non-printing chars like null, bell, etc.)
    ; [[:cntrl:]] is a POSIX class that matches characters 0-31 and 127.
    s := RegExReplace(s, "[[:cntrl:]]", "")

    ; 2. Trim both ends of ALL whitespace
    ; \s matches space, tab, and newlines. 
    ; \x{00A0} specifically targets the dreaded Non-Breaking Space.
    return RegExReplace(s, "^[\s\x{00A0}]+|[\s\x{00A0}]+$")
}

;==============================================================================
; Date and Time
;==============================================================================

/**
 * AddDays(dateStr, d)
 * @param dateStr - String in 'M/D/YYYY' format
 * @param d - Number of days to add
 */
add_days(dateStr, d) {
    ; 1. Split the string into [M, D, YYYY]
    parts := StrSplit(dateStr, "/")

    ; 2. Format into YYYYMMDD000000
    ; We use Format() to ensure 5/8 becomes 0508 (adding the leading zeros AHK needs)
    timestamp := Format("{:04}{:02}{:02}000000", parts[3], parts[1], parts[2])

    ; 3. Add the days
    newTimestamp := DateAdd(timestamp, d, "Days")

    ; 4. Convert back to M/D/YYYY format
    return FormatTime(newTimestamp, "M/d/yyyy")
}


;===============================================================================
; Sleep
;===============================================================================

sleepRandomSeconds(min, max) {
    min *= 1000
    max *= 1000

	sleepTime := Random(min, max)
    Sleep(sleepTime)
}


;==============================================================================
; Keyboard
;==============================================================================

; Send and Sleep.
SendS(s) {
	global delay
	Send(s)
	Sleep(delay)
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


;==============================================================================
; GUI
;==============================================================================

RemoveToolTip() => ToolTip()


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
	; Functions and variables share the same global namespace.
	; So, you'd be overwriting this function if you used 'exists' as the variable.
	; And, you'd be trying to assign to a global without declaring it global.
    exists_ := FileExist(path) ; returns an attribute string for the file or empty if DNE
    if (exists_) {
        exists_ := true
    }
    else {
        exists_ := false
    }
    
    return exists_
}


;==============================================================================
; Google Sheets
;==============================================================================

get_cell_location() {
	A_Clipboard := ""
	SendS("^j") ; go to name box (has cell name/location)
	Sleep(30)
	SendS("^c")
	ClipWait(2)
	location := Exorcise(A_Clipboard)
	SendS("{enter}") ; return to cell
	Sleep(30)
	return location
}

move_to_cell(location) {
	SendS("^j")
	Sleep(30)
	SendS(location)
	SendS("{enter}")
	Sleep(30)
}

move_to_next_empty_cell() {
	saved := A_Clipboard
	; Find next empty cell.
	Loop {
		temp_value := get_cell_value()
		if (temp_value != "") {
			SendS("{Down}")
		}
		else { ; blank cell found
			break
		}
	} ; loop
	A_Clipboard := saved
}

get_cell_value(clear := false) {
	A_Clipboard := ""
	SendS("^c")
	ClipWait(2)
	; I think we need to not exorcise the value when just doing copy/paste between cells.
	; Nope, I was wrong. When searching for a blank, it went into an infinite loop.
	value := Exorcise(A_Clipboard)
	if (clear) {
		Sleep(30)
		SendS("{backspace}")
	}
	return value
}

get_raw_cell_value() {
	A_Clipboard := ""
	SendS("^c")
	ClipWait(2)
	value := A_Clipboard
	return value
}

; Prepare a raw cell to merge with another. 
clean_cell_for_merge(raw_cell) {
    ; 1. Remove the trailing newline Sheets always adds
    cooked_cell := RTrim(raw_cell, "`r`n")
    
    ; 2. If the cell was multiline, Sheets wrapped it in quotes.
    ; We check if it starts and ends with a quote.
    if (SubStr(cooked_cell, 1, 1) = '"' && SubStr(cooked_cell, -1) = '"') {
        ; Strip the outer quotes
        cooked_cell := SubStr(cooked_cell, 2, -1)
        ; Sheets doubles internal quotes (escaping). Change "" back to "
        cooked_cell := StrReplace(cooked_cell, '""', '"')
    }
    return cooked_cell
}

merge_cells(raw_cell1, raw_cell2) {
	clean_cell1 := clean_cell_for_merge(raw_cell1)
	clean_cell2 := clean_cell_for_merge(raw_cell2)
	merged_cell := clean_cell1 . "`n" . clean_cell2
	; Quote any quotes in the merged cell content.
	merged_cell := StrReplace(merged_cell, '"', '""')
	; Wrap the whole thing in double quotes so it gets pasted as a single cell.
	merged_cell := '"' . merged_cell . '"'
	return merged_cell
}

; Get name of the active sheet.
get_sheet_name() {
	local sheet := "unknown"

	location := get_cell_location()
	move_to_cell("A1")
	value := get_cell_value()
	if (value = "Progressive Tasks [5]") {
		sheet := "Kanban"
	}
	else if (value = "Task") {
		sheet := "Recurring"
	}
	else if (value = "Date") {
		sheet := "Scheduled"
	}
	move_to_cell(location)
	return sheet
}


;===============================================================================
; Properties
;===============================================================================

; Returns the value of the given property from ~/.properties.
property(key) {
	; PRE: HOME is set to home dir by script including this library.
	; Global vars are global across all files (unlike in Python).
	global HOME
    propFile := HOME "\.properties"
    
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

; Manual implementation of MonitorGetFromPoint for AHK v2.0.
; This function is available in AHK v2.1 alpha.
MonitorGetFromPoint(X, Y) {
    Count := MonitorGetCount()
    Loop Count {
        MonitorGet(A_Index, &L, &T, &R, &B)
        if (X >= L && X <= R && Y >= T && Y <= B)
            return A_Index
    }
    return MonitorGetPrimary() ; Fallback to primary if not found
}

; Returns the number of the active monitor.
activeMonitor() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    
    ; MonitorGetFromPoint returns the index of the monitor containing the specified coordinates.
    return MonitorGetFromPoint(mx, my)
}

activeMonitorName() {
	global HOST
	if (HOST = "Zenbook") {
		monitorName := "Zenbook"
	}
	return monitorName
}


; Returns the name of the active Google Sheet within a workbook.
activeSheet() {
	global HOST
    CoordMode("Mouse", "Window")
    CoordMode("Pixel", "Window")

    monitors := MonitorGetCount()

    active_sheet := "unknown"

    ; ASUS Zenbook 14X OLED
    if (StrLower(HOST) == "zenbook") {
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
            active_sheet := "Kanban"
        else if isActive(800, 1650)
            active_sheet := "Rocks"
        else if isActive(580, 1650)
            active_sheet := "Recurring"

        ; tabColor := PixelGetColor(580, 1650, "RGB")
        ; MsgBox("Zenbook tab color: " tabColor "`nActive: " activeTabColor, , "T1")
    }

    return active_sheet
}

;===============================================================================
; Sound
;===============================================================================

; Speaks given message using computer-generated voice.
speak(message) {
    ; In v2, you must declare 'global' to READ a variable 
    ; if it's not passed as a parameter.
    global OPT_SPEAK	
    
    if (IsSet(OPT_SPEAK) && OPT_SPEAK) {
        ; ComObject replaces ComObjCreate
        ComObject("SAPI.SpVoice").Speak(message)	
    }
}

