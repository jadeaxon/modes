#Requires AutoHotkey v2.0

#Include ../Lib/Test.ahk
#Include ../Lib/List.ahk

L := List([1, 2, 3])
e := L.pop()
assert_equal(e, 3)

L.append("last")
L[1] := "two"

e := L[1]
assert_equal(e, "two")
e := L[-1]
assert_equal(e, "last")

L.extend([4, 5])
i := L.index(4)
assert_equal(i, 3)

MsgBox("All tests passed!")
ExitApp(0)


