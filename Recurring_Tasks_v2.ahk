#Requires AutoHotkey v2.0

#SingleInstance Force

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

; Defer recurring task for a day, a week, or a month.
$d:: {
	savedHwnd := WinExist("A")
	
	choice := getTimeDeferred()
	days := 0
	switch choice {
		case "day":
			days := 1
		case "week":
			days := 7
		case "month":
			days := 30
	}
	WinActivate("ahk_id " . savedHwnd)
	WinWaitActive("ahk_id " . savedHwnd)

	if (days) {
		Loop 5 {
			SendS("{right}")
		}
		; Copy the date.
		A_Clipboard := ""
		SendS("^c")
		ClipWait(2)
		date := A_Clipboard
		date := add_days(date, days)
		A_Clipboard := ""
		A_Clipboard := date
		ClipWait(2)
		SendS("^v")
		Loop 5 {
			SendS("{left}")
		}
		SendS("{up}")
	}
} ; d hotkey

getTimeDeferred() {
    myGui := Gui("+AlwaysOnTop", "Defer Task")
    myGui.SetFont("s10", "Segoe UI")
    myGui.Add("Text",, "Defer for how long?")
    
    choice := ""

	myGui.OnEvent("Escape", (guiObj) => guiObj.Hide())
    myGui.Add("Button", "Default w80", "&Day?").OnEvent("Click", (btn, *) => (choice := btn.Text, myGui.Hide()))
    myGui.Add("Button", "x+10 w80", "&Week?").OnEvent("Click", (btn, *) => (choice := btn.Text, myGui.Hide()))
    myGui.Add("Button", "x+10 w80", "&Month?").OnEvent("Click", (btn, *) => (choice := btn.Text, myGui.Hide()))

    myGui.Show()
    
    ; This loop keeps the function from returning until a button or Esc is pressed.
    while (WinExist("ahk_id " myGui.Hwnd) && DllCall("IsWindowVisible", "Ptr", myGui.Hwnd))
        Sleep(50)

	choice := StrReplace(choice, "&")
	choice := StrReplace(choice, "?")
	choice := StrLower(choice)
	myGui.Destroy()
    return choice
}


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

