#Requires AutoHotkey v2.0

#Include ..\Lib\Library_v2.ahk

date := A_YYYY . "-" . A_MM . "-" A_DD
fname := "bookmarks-" . date . ".json"
f := "C:\Users\jadea\Desktop\" . fname
if FileExist(f)
	FileDelete(f)

WinActivate("ahk_exe firefox.exe")
WinWaitActive("ahk_exe firefox.exe")

SendS("^+o") ; manage bookmarks
Sleep(500)
SendS("!i")
Sleep(300)
SendS("b")
if WinWaitActive("Bookmarks backup filename",, 5) {
	Sleep(500)	
	SendS("{enter}")

	while !FileExist(f) {
		Sleep(200)
	}

	bdir := "G:\My Drive\Backups\Firefox\" 
	target := bdir . fname

	FileCopy(f, target, true)

	while !FileExist(target) {
		Sleep(200)
	}

	Run bdir
}
else {
	MsgBox("Failed to open save dialog.")
}

