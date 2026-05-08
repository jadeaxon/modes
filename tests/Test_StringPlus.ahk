#Requires AutoHotkey v2.0

; FAIL: Can't find a way to use <> include and put tests in their own subdir.
; #Include <StringPlus>
#Include ../Lib/StringPlus.ahk

s := StringPlus("test ")
s := s.repeat(3).strip()
b := s.endswith("st")
b2 := s.startswith("tes")
MsgBox(Format("'{}' {} {}", s.str(), b, b2))

