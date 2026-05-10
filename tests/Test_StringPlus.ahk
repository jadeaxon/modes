#Requires AutoHotkey v2.0

; FAIL: Can't find a way to use <> include and put tests in their own subdir.
; #Include <StringPlus>
#Include ../Lib/Test.ahk
#Include ../Lib/StringPlus.ahk

s := StringPlus("test ")
s := s.repeat(3).strip()
b := s.endswith("st")
b2 := s.startswith("tes")
assert(b)
assert(b2)

s := StringPlus("try using []s")
s[0] := "really t"
s[-1] := "s for profit"
e := "really try using []s for profit"
assert_equal(s.str(), e)

s := StringPlus("UPPER CASE")
s := s.lower()
assert_equal(s.str(), "upper case")
s := s.upper()
assert_equal(s.str(), "UPPER CASE")

s := StringPlus("{} and {}")
s2 := s.format("peanut butter", "jelly")
assert_equal(s2.str(), "peanut butter and jelly")

item := "pizza"
price := 4.2975
s := StringPlus("The {item} costs ${price:.2f}.")
s2 := s.interpolate()
assert_equal(s2.str(), "The pizza costs $4.30.")
item := "yogurt"
price := "1.2933"
s2 := s.interpolate()
assert_equal(s2.str(), "The yogurt costs $1.29.")

MsgBox("All tests passed!")
ExitApp(0)

