#Requires AutoHotkey v2.0

TraySetIcon(A_ScriptDir "\Icons\Debug_v2.ico")

; Use mouse coordinates relative to the active window.
CoordMode("Mouse", "Window")

$h:: {
	message := "h => help`n"
	message .= "<C Esc> => exit submode`n"
	message .= "H => open AHK help for word at cursor`n"
	message .= "k => show keystroke history`n"
	message .= "p => report mouse position`n"

	MsgBox(message)
}

; Make h close the help message box.
#HotIf WinActive("ahk_class #32770")
h:: {
    WinClose("A")
}
#HotIf

; Open AHK help docs for the word under the mouse.
; BUG: Doesn't work in Cygwin Vim. Does work in gVim.
+h:: {
    Click(2) ; Double-click to select the word
    A_Clipboard := "" ; Clear clipboard for ClipWait
    Send("^c")
    if !ClipWait(1) {
        return
    }
    
    helpPath := "C:\Program Files\AutoHotkey\v2.0.26\AutoHotkey.chm"
    title := "AutoHotkey v2 Help"

    if FileExist(helpPath) {
		if !WinExist(title) {
			Run(helpPath)
		}
        if WinWait(title, , 3) {
            WinActivate(title)
			WinMaximize(title)
            Send("!s") ; Open search
            Sleep(50)
			Send("^+{backspace}") ; delete any existing search
            
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

RemoveToolTip() => ToolTip()

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Debug mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

