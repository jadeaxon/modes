#Requires AutoHotkey v2.0
#SingleInstance Force

; While you can't tell what mailbox you are in from the window title, you can
; tell from the URL. So, you could just use <C l><C c><Esc><Esc> to get it.

TraySetIcon("Yahoo.ico")

; Calculate today's date in YYYY-MM-DD format
today := FormatTime(, "yyyy-MM-dd")

times_pressed := 0

#HotIf WinActive("Yahoo Mail ahk_exe chrome.exe")
^d:: {
	global times_pressed
	;MsgBox("activated")
	times_pressed += 1

	if (times_pressed = 1) {
		Send("/") ; Focus search
		Sleep(300)
		Send("^a{Backspace}") ; clear search field
		Sleep(300)
		Send("after:" today)
		Sleep(500)
		Send("{enter}")
		Sleep(1000) ; Wait for search to load
		Send("^a") ; Select all results
	}
	else {
		MsgBox("Deleting email.")
		times_pressed := 0
	}
}
#HotIf

