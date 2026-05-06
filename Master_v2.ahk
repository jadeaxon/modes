;===============================================================================
; Main
;===============================================================================

; FAIL: AHK v2 syntax highlighting does not work in Vim.
#Requires AutoHotkey v2.0

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

; Group all Explorer windows.
GroupAdd("ExplorerGroup", "ahk_class CabinetWClass")
GroupAdd("ExplorerGroup", "ahk_class ExploreWClass")

; Let kanban hotkeys/hotstrings work with Firefox and Chrome.
GroupAdd("PersonalKanban", "Personal Kanban ahk_class MozillaWindowClass")
GroupAdd("PersonalKanban", "Personal Kanban ahk_class Chrome_WidgetWin_1")

GroupAdd("WorkKanban", "Work Kanban ahk_class MozillaWindowClass")
GroupAdd("WorkKanban", "Work Kanban ahk_class Chrome_WidgetWin_1")

; Is mouse click locked down via CapsLock hotkey?
; In v2, 'false' and 'true' are built-in keywords.
mouseDownLock := false

; Have we cut a kanban item to the clipboard?
kanbanCut := false

; Are the left Control and Shift keys mapped to sending down/up keystrokes?
; Controlled by a checkbox in the Modes GUI (<A-W m>).
OPT_LEFT_SCROLL := 0

; Speak when hotkeys/hotstrings are triggered?
OPT_SPEAK := 0

; The hotkey for pressing w.
W_HOTKEY := "not set"

; Is the search dialog open in a Google Sheet?
searchDialog := 0

; The color of a pixel. In hex format. 
; v2 uses 0x prefix for hex; v1 style "000000" strings should be 0x000000 numbers.
color := 0

; Delay between keystrokes.
delay := 30

; Context menu position for Slack reminders.
menuPosition := 0

vUserProfile := EnvGet("USERPROFILE")
host := EnvGet("COMPUTERNAME")

HOME := EnvGet("USERPROFILE")
Run(HOME "\AHK\AutoCorrect2\Core\AutoCorrect2.exe")

; CONVERTED


^+h::
{
    MsgBox("Hello, AHK v2!")
}

