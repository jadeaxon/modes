#Requires AutoHotkey v2.0

HOME := EnvGet("USERPROFILE")
HOST := EnvGet("COMPUTERNAME")
delay := 30


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

get_raw_cell_value(clear := false) {
	A_Clipboard := ""
	SendS("^c")
	ClipWait(2)
	value := A_Clipboard
	if (clear) {
		Sleep(30)
		SendS("{backspace}")
	}
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

delete_first_cell_line(cell) {
    ; Check if the string is empty or has no content
    if (cell == "")
        return ""

    ; Look for the first newline (supports `\r\n` or just `\n`)
    ; Pos is the position of the first `\n` character
    if (i := InStr(cell, "`n")) {
        ; Return everything starting from the character after the newline
        ; return SubStr(cell, i + 1)
        return SubStr(cell, i)
    }

    ; If no newline was found, it means there was only one line.
    ; Python's logic would return an empty string here.
    return ""
}

/**
 * Cleans Google Sheet cell text.
 * 1. Removes a trailing double-quote if present.
 * 2. Consolidates 2+ empty lines into a single empty line.
 */
clean_merged_cell(cell) {
	; 1. Clean the internal data first
	val := Trim(cell, " `t`n`r")
	val := RegExReplace(val, '^"|"$') ; Remove existing wrapping quotes
	val := RegExReplace(val, "\R{3,}", "`r`n`r`n")
	
	; 2. Escape any INTERNAL double quotes by doubling them
	; This is required so Sheets doesn't think the string ends early
	val := StrReplace(val, '"', '""')

	val := RegExReplace(val, '"+$', "")

	; 3. Wrap the WHOLE thing in quotes to force it into one cell
	return '"' . val . '"'
}

advance_one_day() {
	; move to C2
	move_to_cell("C2")
	; cut it
	cell_C2 := get_raw_cell_value(true)
	; delete first line
	modified_cell_C2 := delete_first_cell_line(cell_C2)
	; move to B2
	SendS("{left}")
	; cut it
	cell_B2 := get_raw_cell_value(true)
	; merge(B2, modified C2)
	merged := merge_cells(cell_B2, modified_cell_C2)
	clean := clean_merged_cell(merged)
	A_Clipboard := clean
	; paste merged to C2
	SendS("{right}")
	Sleep(30)
	SendS("^+v")
	Sleep(100)
	; cut B3:B8
	A_Clipboard := ""
	move_to_cell("B3")
	SendS("{shift down}")
	SendS("{down}")
	SendS("{down}")
	SendS("{down}")
	SendS("{down}")
	SendS("{down}")
	SendS("{shift up}")
	SendS("^c")
	SendS("{backspace}")
	; paste to B2:B7
	move_to_cell("B2")
	Sleep(30)
	SendS("^+v")
	Sleep(100)
	; add day header to C8 (like THU: 8th)
	move_to_cell("B8")
	value := new_cell_header()
	A_Clipboard := value
	SendS("^+v")
	Sleep(100)
	move_to_cell("C2")
}

/**
 * Returns a week from tomorrow's date formatted as "DAY: Dth" (no leading zero).
 */
new_cell_header() {
    day := DateAdd(A_Now, 8, "Days")
    
    ; "ddd" = Abbreviated day (Sun)
    ; "d"   = Day of month WITHOUT leading zero (9)
    DDD := StrUpper(FormatTime(day, "ddd"))
    day_num  := FormatTime(day, "d")
  
	ordinal_day := ordinal(day_num)
    return DDD ": " ordinal_day
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

change_brightness(amount) {
    local current := get_brightness()
    local brightness := current + amount
    
    if (brightness > 100)
        brightness := 100
    else if (brightness < 0)
        brightness := 0
        
    set_brightness(brightness)
}

get_brightness() {
	local property
    for property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
        return property.CurrentBrightness
    return 50 ; fallback
}

set_brightness(brightness) {
	local property
    for property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
        property.WmiSetBrightness(0, brightness)
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

