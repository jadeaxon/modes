#Requires AutoHotkey v2.0

#SingleInstance Force

#Include <Library_v2>

TraySetIcon(A_ScriptDir "\Icons\Kanban_v2.ico")

#HotIf WinActive("Personal Kanban ahk_class Chrome_WidgetWin_1")
#Requires AutoHotkey v2.0

; This hotkey only triggers when Google Sheets is the active window
#HotIf WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe msedge.exe") or WinActive("ahk_class MozillaWindowClass")

; Adds a plus to the cell as a mark of progress.
; +'s are in groups of 4.
; If there's a ], the +'s start there.
; If not, they go on their own line at the bottom.

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
    } else {
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
}


#HotIf


; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Kanban mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

