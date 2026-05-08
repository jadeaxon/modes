#Requires AutoHotkey v2.0

TraySetIcon(A_ScriptDir "\Icons\Recurring_Tasks_v2.ico")

#HotIf WinActive("Personal Kanban ahk_class Chrome_WidgetWin_1")
; Skip recurring task. Mark it "done" as of today.
$s:: {
	Loop 5 {
		SendS("{right}")
	}
	SendS("^;")
	Loop 5 {
		SendS("{left}")
	}
	SendS("{up}")
}

; Skip dealing with this recurring task for the moment.
$+s:: {
	SendS("{up}")
}

; Send and Sleep.
delay := 30
SendS(s) {
	global delay
	Send(s)
	Sleep(delay)
}
#HotIf

RemoveToolTip() => ToolTip()

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Recurring Tasks mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

