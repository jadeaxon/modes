#Requires AutoHotkey v2.0

#Include ..\Lib\Library_v2.ahk

; FAIL:
; Gemini couldn't get it to work using UIA.
; #Include <UIA>
; UIA is from https://github.com/Descolada/UIA-v2/blob/main/Lib/UIA.ahk
; It's in C:\Users\jadea\Documents\AutoHotkey\Lib

f := "C:\Users\jadea\Downloads\Personal Kanban.xlsx"
if FileExist(f)
	FileDelete(f)

WinActivate("Personal Kanban ahk_exe chrome.exe")
Sleep(2000)

SendS("^+f") ; open menu
Sleep(500)
SendS("!f") ; open file menu
SendS("d") ; download
SendS("x") ; as Excel

while !FileExist(f) {
	Sleep(200)
}

SendS("{Esc}")
SendS("^+f") ; close menu

date := A_YYYY . "-" . A_MM . "-" A_DD
target := "G:\My Drive\Backups\Kanbans\Personal Kanban " . date . ".xlsx"

FileCopy(f, target, true)

while !FileExist(target) {
	Sleep(200)
}
Run "G:\My Drive\Backups\Kanbans"

