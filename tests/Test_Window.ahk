#Requires AutoHotkey v2.0

#Include ../Lib/Test.ahk
#Include ../Lib/Window.ahk

w := Window("ahk_exe firefox.exe")
title := w.title()
;MsgBox(title)
w.set_title("custom title")
w.maximize()
w.wait_active()
Sleep(1000)
assert(w.is_active(), true)
w.minimize()
Send("!{Tab}")
w.close()
Run "https://www.autohotkey.com"
w.rebind()
w.minimize()

; MsgBox("All tests passed!")
ExitApp(0)


