; How long to wait between each screen rescan when looking for a symbol. 
symbolPollingPeriod := 1000


;===============================================================================
; Visual Expecting
;===============================================================================


setSymbolPollingPeriod(milliseconds) {
    global symbolPollingPeriod
    symbolPollingPeriod := milliseconds
    
}

; Wait for a graphical symbol to appear on the screen.
;
; If symbol file is a directory, then try to match against any image file in that directory.
waitForSymbol(symbolFile, timeoutSeconds) {
    waited := 0
    while (foundX = "") {
        ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %symbolFile%
        Sleep 200
        waited += 200
        if (waited > (timeoutSeconds * 1000)) {
            MsgBox ERROR: Could not see symbol %symbolFile% after %timeoutSeconds%.
            ErrorLevel := 1
            return false
        }
    } ; next check
    
    ; MsgBox %foundX% %foundY%
    return true

} ; waitForSymbol(...)


; Waits to see an exact match on the screen with any image file in the give directory.
waitForAnyExactSymbol(directory, timeoutSeconds) {
    global symbolPollingPeriod
    
    ; MsgBox,,, waitForAnyExactSymbol(...)
            
    foundX := ""
    
    waited := 0
    while (foundX = "") {
        ; Iterate over all the files in a folder.
        Loop, %directory%\* {
            ; Write to stdout.
            ; FileAppend, %A_LoopFileFullPath%`n, *
            symbolFile := A_LoopFileFullPath
            
            ; MsgBox,,, %symbolFile%
            ; print("Searching for " . %symolFile%)
            
            ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %symbolFile%
        
        
            if (foundX) {
                break
            }
        
        } ; next file
        
        ; TODO: This should delta time since start of funtion, not use an accumulator.
        Sleep symbolPollingPeriod
        waited += symbolPollingPeriod
    
        if (waited > (timeoutSeconds * 1000)) {
            MsgBox ERROR: Did not see any symbol in %directory% within %timeoutSeconds%.
            ErrorLevel := 1
            return false
        } ; if
        
        print("")
        
    } ; next check
    
    print("Found symbol.")
    return true
    
} ; waitForAnyExactSymbol(directory, timeoutSeconds)


waitForExactSymbol(symbolFile, timeoutSeconds) {
    waited := 0
    while (foundX = "") {
        ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %symbolFile%
        Sleep 200
        waited += 200
        if (waited > (timeoutSeconds * 1000)) {
            MsgBox ERROR: Could not see symbol %symbolFile% after %timeoutSeconds%.
            ErrorLevel := 1
            return false
        }
    } ; next check
    
    ; MsgBox %foundX% %foundY%
    return true
    
} ; waitForExactSymbol(...)


symbolIsVisible(symbolFile) {
    ImageSearch, foundX, foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %symbolFile%
    if (foundX = "") {
        return false
    }
    return true
}

;===============================================================================
; Shortkeys
;===============================================================================

; Check to see if ShortKeys is running and enabled (not suspended).
ShortKeysIsEnabled() {
	file := A_ScriptDir . "\Symbols\ShortKeys\Tray Icon.bmp"
    
    ImageSearch, iconX, iconY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %file% 
    
    if (iconX = "") {
        return false
    }

	return true
	
} ; ShortKeysIsEnabled()


; Check to see if ShortKeys is running.
; I got an apparent false negative once from this.
ShortKeysIsRunning() {
    file := A_ScriptDir . "\Symbols\ShortKeys\Tray Icon.bmp"
    sfile := A_ScriptDir . "\Symbols\ShortKeys\Tray Icon (Suspended).bmp"
    
    ImageSearch, iconX, iconY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %file% 
    
    if (iconX = "") {
        ImageSearch, iconX, iconY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %sfile%
    }
    else { ; Found.
        return true
    }
    
    ; We didn't find the normal icon.  Did we find the suspended icon?
    if (iconX = "") {
        return false
    }
    
    return true
    
} ; ShortKeysIsRunning()


; Toggles ShortKeys suspended/running status via the tray icon popup menu.
; DEPRECATED: Just use <Window + S> to toggle ShortKeys.
toggleShortKeys() {
    CoordMode, Pixel, Screen
    CoordMode, Mouse, Screen
    
    MouseGetPos, oldX, oldY ; Save mouse position to restore later.
    
    file := A_ScriptDir . "\Symbols\ShortKeys\Tray Icon.bmp"
    sfile := A_ScriptDir . "\Symbols\ShortKeys\Tray Icon (Suspended).bmp"
    
    ImageSearch, iconX, iconY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %file% 
    
    if (iconX = "") {
        ImageSearch, iconX, iconY, 0, 0, A_ScreenWidth, A_ScreenHeight, *10 %sfile%
    }

    if (ErrorLevel = 2) {
        MsgBox Could not conduct the search.
    }
    else if (ErrorLevel = 1) {
        MsgBox Icon could not be found on the screen.
    }
    else { ; Found it.
        activeWindow := WinExist("A")
        
        ; MsgBox The icon was found at %iconX%x%iconY%.
        Click Right %iconX%, %iconY%
        Sleep 50
        Send s
        Sleep 50
        MouseMove, %oldX%, %oldY%
        
        if (activeWindow) {
            WinActivate ahk_id %activeWindow%
        }
        
    } ; else
    
    CoordMode, Pixel, Relative 
    CoordMode, Mouse, Relative
 
    return

} ; toggleShortKeys()



;===============================================================================
; Sleep
;===============================================================================

sleepRandomSeconds(min, max) {
    min *= 1000
    max *= 1000
    
    Random, sleepTime, min, max
    
    Sleep sleepTime
	
}


;===============================================================================
; Mouse
;===============================================================================

; Randomly moves to a point within given rectangle.  Top left corner is (x, y).
randomlyMoveMouseTo(x, y, width, height) {
    Random, randX , x, x + width
    Random, randY, y, y + height
    
    mouseSpeed := 10 ; 0 .. 100, smaller is faster
    MouseMove, randX, randY, mouseSpeed
    
    ; MsgBox,,, %randX% %randY%
    
}

;===============================================================================
; Filesystem
;===============================================================================

; Return a tab separated list of all files in the given directory.
; Return just name and extension, not full path.
listFiles(directory) {
    
}


; Is the given path an existing directory?
isDirectory(path) {
    FileGetAttrib, attributes, %path%
    IfInString, attributes, D
    {
        return true
    }
    
    return false
    
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
    
} ; exists(path)

;===============================================================================
; Properties
;===============================================================================

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
; Console
;===============================================================================

; Prints given text to stdout.  Appends a newline.
print(string) {
    ; * => stdout
	FileAppend, %string%`n, *
	
}


; Apparently, function overloading is not allowed.  Lame.
; print() {
;    FileAppend, `n, *
; }






;===============================================================================
; Numeric
;===============================================================================


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
; Dynamic Code Execution
;===============================================================================



; Dynamically run a piece of AHK code.  Looks like it writes a temporary file and spawns another process.
; Not true dynamic code.  Loses context.  Has extra process overhead.
; 
; The pipename is the name of the temporary script that will be used.  Thus, the process name in dialog windows, etc.
;
; The DynaRun call does not block.  It creates the new proces and immediately executes the next line of code in its parent script.
DynaRun(TempScript, pipename="") {
   static _:="uint"
   @:=A_PtrSize ? "Ptr" : _
   If pipename =
      name := "AHK" A_TickCount
   Else
      name := pipename
   __PIPE_GA_ := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   __PIPE_    := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
   if (__PIPE_=-1 or __PIPE_GA_=-1)
      Return 0
   Run, %A_AhkPath% "\\.\pipe\%name%",,UseErrorLevel HIDE, PID
   If ErrorLevel {
      MsgBox, 262144, ERROR,% "Could not open file:`n" A_AhkPath """\\.\pipe\" name """"
      DllCall("CloseHandle",@,__PIPE_GA_)
      DllCall("CloseHandle",@,__PIPE_)
      Return
   }
   DllCall("ConnectNamedPipe",@,__PIPE_GA_,@,0)
   DllCall("CloseHandle",@,__PIPE_GA_)
   DllCall("ConnectNamedPipe",@,__PIPE_,@,0)
   script := (A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) . TempScript
   if !DllCall("WriteFile",@,__PIPE_,"str",script,_,(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),_ "*",0,@,0)
      Return A_LastError
   DllCall("CloseHandle",@,__PIPE_)
   Return PID

} ; DynaRun(...)


;===============================================================================
; Pidgin
;===============================================================================

; If a Pidgin conversation window is open, maximize it.
maximizePidgin() {



} ; maximizePidgin


;===============================================================================
; Windows
;===============================================================================

; Returns scale factor necessary to adjust for DPI settings.
; FAIL: Does not work!
dpiScaleFactor(options = "") {

    if (options = "REG") {
        RegRead, DPI, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
        return (errorlevel = 1) ? 96 : DPI
    }

    x := dllcall("GetDC")
    dpi := dllcall("GetDeviceCaps", UINT, x , UINT, 88)
    dllcall("ReleaseDC", INT, 0, UINT, x)

    dpi := dpi ? dpi : 96
    scaleFactor := dpi / 96.0
    return scaleFactor
}


;===============================================================================
; Display
;===============================================================================

; Switches screen on XPS15 to normal display profile.
normalDisplayProfile() {
	; Activate normal display profile.
	Send #m
	WinActivate Program Manager ahk_class Progman
	WinActivate Program Manager ahk_class Progman
	WinWaitActive Program Manager ahk_class Progman
	Send {Escape 2} ; Clear any selected item.	
	Send {AppsKey}
	; BUG: Sometimes 'Graphics Options' is slot 10.	
	Send {Down 11}
	Send {vk27sc14D} ; {Right}
	Send {Down 4}
	Send {vk27sc14D} ; {Right}
	Send {vk27sc14D} ; {Right}
	Send {Down}
	Send {Enter}
} ; normalDisplayProfile()


; Switches screen on XPS15 to bedtime display profile.
bedtimeDisplayProfile() {
	Send #m
	WinActivate Program Manager ahk_class Progman
	WinActivate Program Manager ahk_class Progman
	WinWaitActive Program Manager ahk_class Progman
	Send {Escape 2} ; Clear any selected item.	
	Send {AppsKey}
	; BUG: Sometimes 'Graphics Options' is slot 10.	
	Send {Down 11}
	Send {vk27sc14D} ; {Right}
	Send {Down 4}
	Send {vk27sc14D} ; {Right}
	Send {vk27sc14D} ; {Right}
	; Send {Enter}
} ; bedtimeDisplayProfile()




