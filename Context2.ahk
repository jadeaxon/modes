#SingleInstance, Force
SetBatchLInes, -1

WinWait, ahk_class #32768
SendMessage, 0x1E1, 0, 0      ; MN_GETHMENU
hMenu := ErrorLevel
sContents := GetMenu(hMenu)
WinWaitClose

MsgBox, % sContents


GetMenu(hMenu) {
   Loop, % DllCall("GetMenuItemCount", "Uint", hMenu)
   {
      idx := A_Index - 1
      idn := DllCall("GetMenuItemID", "Uint", hMenu, "int", idx)
      nSize++ := DllCall("GetMenuString", "Uint", hMenu, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)
      VarSetCapacity(sString, nSize)
      DllCall("GetMenuString", "Uint", hMenu, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;MF_BYPOSITION
      If !sString
         sString := "---------------------------------------"
      sContents .= idx . " : " . idn . A_Tab . A_Tab . sString . "`n"
      If (idn = -1) && (hSubMenu := DllCall("GetSubMenu", "Uint", hMenu, "int", idx))
         sContents .= GetMenu(hSubMenu)
   }
   Return   sContents
}