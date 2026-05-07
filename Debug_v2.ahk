#Requires AutoHotkey v2.0

TraySetIcon(A_ScriptDir "\Icons\Debug_v2.ico")

; Use mouse coordinates relative to the active window.
CoordMode("Mouse", "Window")

; This gives you details on what keystrokes have been pressed recently.
; Including scan codes and virtual key numbers.
k:: {
	KeyHistory()
}

; Report mouse position.
p:: {
	local x
	local y
	MouseGetPos(&x, &y) 
	Msgbox(Format("The mouse is at window coordinates {} {}.", x, y)) 
}


; Open AHK help docs for the word under the mouse.
h::	{
    Click(2) ; Double-click to select the word
    A_Clipboard := "" ; Clear clipboard for ClipWait
    Send("^c")
    if !ClipWait(1) {
        return
    }
    
    helpPath := "C:\Program Files\AutoHotkey\v2.0.26\AutoHotkey.chm"
    
    if FileExist(helpPath) {
        Run(helpPath)
        if WinWait("AutoHotkey v2 Help", , 3) {
            WinActivate("AutoHotkey v2 Help")
			WinMaximize("AutoHotkey v2 Help")
            Send("!s") ; Open search
            Sleep(50)
            
            Suspend(true) ; Prevent 'h' from re-triggering while typing search
            Send(A_Clipboard)
            Suspend(false)
            
            Sleep(50)
            Send("{Enter}")
        }
    } 
	else {
        MsgBox("Help file not found at:`n" helpPath)
    }
}

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ExitApp
}

