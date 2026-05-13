#Requires AutoHotkey v2.0
#SingleInstance Force

; Crucial for finding text in modern Windows overlays
DetectHiddenText(True)

SetTitleMatchMode(2)

; Trigger the picker
Send("#;")

; Wait for the window to actually exist so we don't need a hard 'Sleep'
if WinWait("", "CoreInput", 3) {
    emoji_hwnd := WinExist("", "CoreInput")
    MsgBox("Found it! HWND: " . emoji_hwnd)
}
else {
    MsgBox("Window not found within 3 seconds.")
}

