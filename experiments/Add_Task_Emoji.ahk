#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "../Lib/Library_v2.ahk"

#HotIf WinActive("ahk_exe chrome.exe")
d:: {
	SendS "{enter}"
	SendS "{up 6}"
	SendS "{end}"
	SendS "💁"
	SendS "{enter}"
}

n::SendS("{down}")
#HotIf

