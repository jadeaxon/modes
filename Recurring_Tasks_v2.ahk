#Requires AutoHotkey v2.0

#SingleInstance Force

#Include <Library_v2>

TraySetIcon(A_ScriptDir "\Icons\Recurring_Tasks_v2.ico")

; Make h close the help message box.
#HotIf WinActive("ahk_class #32770")
h:: {
    WinClose("A")
}
#HotIf

#HotIf WinActive("Personal Kanban ahk_class Chrome_WidgetWin_1")
$h:: {
	message := "h => help`n"
	message .= "<C Esc> => exit submode`n"
	message .= "f => toggle 'FOR REAL: ' prefix`n"
	message .= "s => skip task; mark it done today`n"
	message .= "d => defer task; choose 1 day, 1 week, or 1 month`n"
	message .= "S => skip task; do nothing and move up to next task`n"
	message .= "n => do task now; copy to kanban Now column`n"
	message .= "t => do task today; append to kanban today cell`n"

	MsgBox(message)
}

; Skip recurring task. Mark it "done" as of today.
$s:: {
	Loop 5 {
		SendS("{right}")
		Sleep(10)
	}
	SendS("^;")
	Sleep(10)
	Loop 5 {
		SendS("{left}")
		Sleep(10)
	}
	SendS("{up}")
}

; Skip dealing with this recurring task for the moment.
$+s:: {
	SendS("{up}")
}

; Do task now. Mark bold and move to Kanban sheet now column. Don't change last done date.
$n:: {
	value := get_raw_cell_value()
	SendS("^b") ; bold
	SendS("!{up}") ; move to Kanban sheet
	move_to_cell("C1")
	move_to_next_empty_cell()
	SendS("^v")
	Sleep(1000)
	SendS("!{down}") ; move back to Recurring sheet
	SendS("{up}")
}

; Mark/toggle this task with 'FOR REAL: '.
$f:: {
    raw := get_raw_cell_value()
    
    ; 1. Clean the raw input (Remove Sheets' trailing newline and outer quotes)
    cleanValue := clean_cell_for_merge(raw)
    
    ; 2. Logic to Toggle the prefix
    if (SubStr(cleanValue, 1, 10) = "FOR REAL: ") {
        finalValue := SubStr(cleanValue, 11) ; Remove the first 10 chars
    } 
	else {
        finalValue := "FOR REAL: " . cleanValue
    }

    ; 3. Prepare for Sheets (The "Single-Cell" Protector)
    ; If it contains a newline, we must wrap in quotes and escape internal quotes
    if InStr(finalValue, "`n") {
        finalValue := StrReplace(finalValue, '"', '""') ; Escape internal quotes
        A_Clipboard := '"' . finalValue . '"'           ; Wrap the whole thing
    } 
	else {
        A_Clipboard := finalValue
    }

    if ClipWait(2) {
        Sleep(30) 
        Send("^v")
    }
}

; Do this today. Mark date as done. Merge with the today cell.
$t:: {
	task := get_raw_cell_value()
	SendS("^b") ; bold
	SendS("!{up}") ; move to Kanban sheet
	move_to_cell("C2")
	today := get_raw_cell_value()
	merged := merge_cells(today, task, true)
	A_Clipboard := merged
	Sleep(20)
	SendS("^v")
	Sleep(1000)
	SendS("!{down}") ; move back to Recurring sheet
	Sends("{up}")
}

; Merge current cell with the one above it.
$m:: {
	value := get_raw_cell_value()
	SendS("{up}")
	value2 := get_raw_cell_value()
	merged := merge_cells(value, value2)
	A_Clipboard := merged
	Sleep(20)
	SendS("^v")
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
	Sleep(20)

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
		SendS("^+v")
		Sleep(20)
		Loop 5 {
			SendS("{left}")
		}
		SendS("{up}")
	}
} ; d hotkey
#HotIf

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

	choice_made := choice ; else these alter button text removing accelerator keys
	choice_made := StrReplace(choice_made, "&")
	choice_made := StrReplace(choice_made, "?")
	choice_made := StrLower(choice_made)
	myGui.Destroy()
    return choice_made
}


; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Recurring Tasks mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

