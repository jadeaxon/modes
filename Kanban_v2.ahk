#Requires AutoHotkey v2.0

#SingleInstance Force

#Include <Library_v2>
#Include <Window>
#Include <StringPlus>

TraySetIcon(A_ScriptDir "\Icons\Kanban_v2.ico")

#HotIf WinActive("Personal Kanban ahk_class Chrome_WidgetWin_1")
#Requires AutoHotkey v2.0

; This hotkey only triggers when Google Sheets is the active window
#HotIf WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe msedge.exe") or WinActive("ahk_class MozillaWindowClass")

; Show help message.
$h:: {
	message := "h => help`n"
	message .= "<C Esc> => exit submode`n"
	message .= "o => open first URL or .txt file mentioned in cell`n"
	message .= "x => execute first AHK script mentioned in cell`n"
	message .= "+ => mark progress by adding a +`n"
	message .= "a => advance kanban forward one day`n"

	MsgBox(message)
}

; Make h close the help message box.
#HotIf WinActive("ahk_class #32770")
h:: {
    WinClose("A")
}
#HotIf

; x => Execute the AHK script mentioned in the cell.
; Has to be at the start of a line. Runs just the first one found.
; Assumes the script is in tasks/ subdir.
$*x:: {
    saved := A_Clipboard
    A_Clipboard := ""
    
    SendS("^c")
    if !ClipWait(2) {
        Send "x" 
        return
    }
    
    RawText := A_Clipboard
    
    ; 1. Clean up Sheets formatting
    CleanText := RegExReplace(RawText, '^"|"$', "")
    CleanText := StrReplace(CleanText, '""', '"')
	
	SendS("^v") ; so the cell copied dotted rectangle goes away
    
    ; 2. Find the first .ahk file at the start of any line
    ; m) enables multiline mode so ^ matches the start of lines within the cell
    if RegExMatch(CleanText, 'm)^[^\s""]+\.ahk', &Match) {
        FileName := Match[0]

        ; Construct the full path: [Main Script Dir]\tasks\[Filename]
        TargetFile := A_ScriptDir "\tasks\" FileName
        
        if FileExist(TargetFile) {
            Run TargetFile
        } 
		else {
            MsgBox("File not found:`n" TargetFile, "Error", 16)
        }
    }
    
    Sleep 100
    A_Clipboard := saved
} ; x hotkey


; o => Open the first URL found in the cell using the default browser.
$*o:: {
    saved := A_Clipboard
    A_Clipboard := ""
    
    Send "^c"
    if !ClipWait(2) {
        Send "o" 
        return
    }
    
    cell := A_Clipboard
    
    ; Clean up Sheets formatting
    CleanText := RegExReplace(cell, '^"|"$', "")
    CleanText := StrReplace(CleanText, '""', '"')
	
	SendS("^v") ; so the cell copied dotted rectangle goes away
    
    ; Using single quotes for the pattern makes literal double quotes much easier
    if RegExMatch(CleanText, 'i)https?://[^\s"]+', &Match) {
        URL := Match[0]
        Run URL
		w := Window("ahk_exe firefox.exe")
		w.rebind() ; waits for window to exist, activates, and waits until active
		end_mode()
    }
	else {
		; See if there is a text file mentioned that we can open.
		open_cell_text_file(cell)
	}
    
    Sleep 100
    A_Clipboard := saved
} ; o hotkey

; + => Add a plus to the cell as a mark of progress.
; +'s are in groups of 4. They go on the last line of the cell.
$*+:: {
    OldClipboard := A_Clipboard
    A_Clipboard := ""
    
    Send "^c"
    if !ClipWait(0.5) {
        Send "+" 
        return
    }
    
    RawText := A_Clipboard
    
    ; 1. Clean the incoming text from Sheets' formatting
    CleanText := RegExReplace(RawText, '^"|"$', "")
    CleanText := StrReplace(CleanText, '""', '"')
    CleanText := RTrim(CleanText, "`r`n`t ")

    ; 2. Determine if we need a new line or just more pluses
    if InStr(CleanText, "+") {
        ; Matches the very last cluster of pluses
        if RegExMatch(CleanText, "\++$", &Match) {
            Addition := (Mod(StrLen(Match[0]), 4) == 0) ? " +" : "+"
        } else {
            ; Case where text exists after the last plus
            Addition := "+"
        }
        
        Send "{F2}{End}"
        Sleep 50
        SendText Addition
        Send "{Enter}"
    } 
	else {
        ; No pluses found: create a new line at the bottom
        Send "{F2}{End}"
        Sleep 50
        Send "!{Enter}" ; Alt+Enter for in-cell newline
        SendText "+"
        Send "{Enter}"
    }
    
    Sleep 100
	Send "{Up}"
    A_Clipboard := OldClipboard
} ; + hotkey

; Advance kanban one day forward.
$a:: {
	advance_one_day()
}

#HotIf

; WARNING: Do not try to migrate this to Library_v2.ahk.
open_cell_text_file(cell) {
	local file := ""
	local s := ""
    ; 1. Clean up Google Sheets wrapping and escaped quotes
    local clean := RegExReplace(cell, '^"|"$', "")
    clean := StrReplace(clean, '""', '"')
    
    /** 
     * 2. Regex Breakdown:
     * m)      = Multiline mode (check every line in the cell)
     * ^       = Start of the line
     * (?:Review\s)? = Non-capturing group: Look for "Review " but don't "keep" it
     * \K      = Forget everything matched so far (discards "Review " if found)
     * .+?\.txt = Match everything greedily until the first .txt
     */
    if RegExMatch(clean, "m)^(?:Review\s)?\K.+?\.txt", &m) {
        file := m[0]
        ; MsgBox("File identified:`n" file, "File Found", 64)
		SendS("!{space}") ; open Launchy
		;SetKeyDelay(7, 7)
		s := StringPlus(file)
		s.removesuffix('.txt')
		;SendEvent(s.str())
		SendS(s.str())
		SendS("{enter}")
		w := Window("ahk_exe gvim.exe")
		w.rebind() ; waits for window to exist, activates, and waits until active
		Sleep(300)
		SendS("/HERE")
		Sends("{enter}")
		end_mode()
    } 
	else {
        ; MsgBox("No .txt file found in the selected cell.", "Not Found", 48)
    }
}


; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	end_mode()
}

end_mode() {
	ToolTip("Kanban mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}


