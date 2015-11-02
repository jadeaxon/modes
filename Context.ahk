setBatchLines, 1
setKeyDelay, 100

;~ run, notepad,,, npPid
  ;~ winWait, % "ahk_pid " npPid
  ;~ winGet, winHwnd, ID

;~ controlClick,, % "ahk_pid " npPid,, right, 1, NA ; simulates the right click.


n::
Click, Right
MsgBox, Done

while !( menuID ) ; Doubles as a menu watch and ID retrieval.
  winGet, menuID, ID, ahk_class #32768

sendMessage, 0x1E1, 0, 0, , ahk_class #32768
mHwnd:=errorlevel

while !( inStr( itemID, -1, 0, 1 ) ) {
  tooltip % itCnt:=( dllCall( "GetMenuItemCount", uInt, mHwnd )-2 ) ; <- item# 0 & 1 = NULL
          . " Menu Item ID's:`n"
          . subStr( itemID.=dllCall( "GetMenuItemID"
          , uInt, mHwnd
          , uInt, a_index+1 )
          . "`n", 1, -4 )
  controlSend,, % ( a_index < itCnt ) ? "{ down }" : "" , % "ahk_id " menuID
}
return

esc::exitApp
