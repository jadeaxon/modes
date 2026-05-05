;===============================================================================
; Main
;===============================================================================

; Warn about using uninitialized variables (On by default in v2, but good to keep)
#Warn

; #NoEnv is removed in v2 as it is the default behavior.

; No longer used.
; #Persistent 

; Only allow one instance of this script to run at a time.
#SingleInstance Force

; Allow match anywhere within title.
SetTitleMatchMode 2

; Set the Tray Icon
; v2 uses A_ScriptDir without percent signs in expressions.
TraySetIcon(A_ScriptDir "\Icons\Master_v2.ico")

; Coordinate mode for Mouse
; In v2, the target (Mouse) and relative-to (Window/Screen) are strings.
CoordMode "Mouse", "Window" ; "Relative" in v1 is "Window" in v2

^+h::
{
    MsgBox("Hello, AHK v2!")
}

