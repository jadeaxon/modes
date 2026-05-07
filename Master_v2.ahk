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
; Controlled by a checkbox in the Modes GUI windo (<C-A j>).
OPT_LEFT_HAND_SCROLL := 0

; Speak when hotkeys/hotstrings are triggered?
OPT_SPEAK := 1

; The hotkey for pressing w.
W_HOTKEY := "not set"

; Is the search dialog open in a Google Sheet?
searchDialog := 0

; The color of a pixel. In hex format. 
; v2 uses 0x prefix for hex; v1 style "000000" strings should be 0x000000 numbers.
; color := 0

; Delay between keystrokes.
delay := 30

; Context menu position for Slack reminders.
menuPosition := 0

vUserProfile := EnvGet("USERPROFILE")
HOST := EnvGet("COMPUTERNAME")

HOME := EnvGet("USERPROFILE")
Run(HOME "\AHK\AutoCorrect2\Core\AutoCorrect2.exe")


;===============================================================================
; Includes
;===============================================================================

#Include "Library_v2.ahk"
;#Include "PL-SQL_v2.ahk"


;===============================================================================
; Hotstrings
;===============================================================================

; Make the hotstrings case-sensitive.
#Hotstring c

; These abbreviations expand in most Windows programs.
; They do not expand in Cygwin.
:*:USAx::United States of America
:*:UVUx::Utah Valley University
:*:ESSx::ERP Software Services

; Some common symbols.  Copyright, registered trademark, and trademark.
:*:(c)::{U+01A9}
:*:(r)::{U+01AE}
:*:(tm)::{U+2123}

#HotIf !WinActive("ahk_exe mintty.exe")
:*:j@h::jadeaxon@hotmail.com
#HotIf

:*:j@g::jadeaxon@gmail.com
:*:je@g::java.emitter@gmail.com
:*:jr@u::jeffrey.anderson@uvu.edu
:*:2@u::10845493@uvu.edu
:*:j@u::jeff.anderson@uvu.edu
:*:my.uvid::10845494
:*:my.pidm::658226

; Misspellings.
::comrad::comrade
:*:digestable::digestible
:*:hazzard::hazard
:*:plateu::plateau
:*:persuassion::persuasion
:*:colocation::collocation

; Python.
:R:py.!::#!/usr/bin/env python3

; 10:30 AM
:*:<t>::
:*:<time>::
{
    ; FormatTime returns the formatted string directly
    output := FormatTime(, "h:mm tt")
    Send(output)
}

; 9/11/2011 9:30 AM
:*:<ts>:: {
    output := FormatTime(, "M/d/yyyy h:mm tt")
    Send(output)
}

; 03/22/2O12
:*:<mdy>:: {
    output := FormatTime(, "MM/dd/yyyy")
    Send(output)
}

; 2018-08-12
::ymd::
:*:<ymd->::
{
	output := FormatTime(, "yyyy-MM-dd")
    Send(output)
}

; 2026-05-06: Wed
:O:ymdd::
{
    datePart := FormatTime(, "yyyy-MM-dd")
    output := datePart ": " A_DDD
    Send(output "{Enter}{Enter}")
}

; Directory abbreviation for Downloads directory.
:*:Aoddl::
:*:Acddl::
{
	Run(HOME "\Downloads")
	speak("Opening downloads folder")	
}

; These are used with items moved to Waiting column in kanban.
:*:@WW::@W: Walmart
:*:@WA::@W: Amazon

; Toggle numberlock.
:*:<numlock>:: {
    Send("{NumLock}")
}

; FAIL: Just does not work right. 
; This should allow it to toggle capslock even if it is one.
; Also, v1 Master.ahk hotkeys that use CapsLock should still work.
/*
:?i:<capslock>::
{
    ; Set the level higher than the v1 hotkey (usually level 0)
    SendLevel(1) 
    
    ; This will now be ignored by other AHK scripts 
    ; but seen by Windows to toggle the actual state
    Send("{CapsLock}")
    
    ; Reset it just to be safe
    SendLevel(0)
}
*/

; Define hotstrings for common person tasks.
; BUG: For some reason, any hotstring with s or w in it is not working.
; I moved some of the hotstrings into RegExHostrings.ahk as a workaround.
#HotIf WinActive("ahk_group PersonalKanban")
:*c:Tbt::Big trash [rD1]{enter}
:*c:Tlw::Laundry (whites) [rD1] {enter}
:*c:Tld::Laundry (darks) [rD1]{enter}
:*c:Tlm::Laundry (mfcs) [rD1]{enter}
:*c:Tlo::Laundry (other) [rD1]{enter}
:*c:Td::Dishes [rD1]{enter}
:*c:Tg::Guitar [rRK1]{enter}
:*c:TAh::Air out house [H1]{enter}
:*c:Tce::Clean/examine 1 drawer [/1]{enter}
:*c:Ttm::50m treadmill{enter}
:*c:T2m::25m treadmill{enter}
:*c:Tst::5m strength training{enter}
:*c:Tbh::Bar hang [H1]^{enter}
#HotIf


;===============================================================================
; Hotkeys
;===============================================================================

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

; Disable NumLock on Zenbook.
; Stops the touchpad numberpad from appearing on Zenbook.
$NumLock:: {
	if (HOST = "Zenbook") {	
		return
	}
	Send("{NumLock}")
}

; Make is so that <Window + Space> does not switch input languages.  This is causing me to nearly die
; in Path of Exile.
#space::return

; By default, <C Down> sends End.  This is not what I want in Firefox.
#HotIf WinActive("ahk_class MozillaWindowClass")
^Down:: {
	Send("{PgDn}")
}

^Up:: {
	Send("{PgUp}")
}
#HotIf

; FAIL: Doesn't work. But, doesn't seem to be necessary anymore either.
; Converts a Wikipedia page to readable/printable view.
; Trigger: Alt+R (only when Firefox is on a Wikipedia page)
/*
#HotIf WinActive("Wikipedia - Mozilla Firefox ahk_class MozillaWindowClass")
!r::
{
    A_Clipboard := "" ; Clear the clipboard
    Send("^l")        ; Select URL in address bar
    Sleep(200)
    Send("^c")        ; Copy selection
    
    ; ClipWait returns 0 (false) if it times out after 2 seconds
    if !ClipWait(2) {
        return
    }

    ; Process the URL
    ; Using RegExMatch to find the position of the subject
    if (RegExMatch(A_Clipboard, "/wiki/(.*)", &match)) {
        subject := match[1]
        printableUrl := "http://en.wikipedia.org/w/index.php?title=" subject "&printable=yes"
        
        ; Put it back on the clipboard and navigate
        A_Clipboard := printableUrl
        if ClipWait(2) {
            Send("^l")
            Sleep(50)
            Send("^v")
            Send("{Enter}")
        }
    }
}
#HotIf
*/

; WARNING: Having this on screws up normal typing.
; Alternate scrolling keys so you're not always using your right hand.
; Only enabled when OPT_LEFT_SCROLL = 1.
; The Modes window <C-A j> sets this.
#HotIf (OPT_LEFT_HAND_SCROLL = 1)
$LShift:: {
	Send("{Up 5}")
}

$LControl:: {
	Send("{Down 5}")
}
#HotIf

; Makes <C-A g> search selected text in Google.
$^!g:: {
    A_Clipboard := "" ; Clear the clipboard
    Send("^c")        ; Copy selected text

    ; Wait up to 2 seconds for text to arrive
    if !ClipWait(2) {
        return
    }

    ; Remove the citation cruft (e.g., from Kindle/Web)
    ; We parse the clipboard and take only the first line.
    loop parse, A_Clipboard, "`n", "`r"
    {
        ; Update the clipboard with just the first line
        A_Clipboard := A_LoopField
        break
    }

    ; Clean the query for the URL (replaces spaces/special chars)
    ; Note: 'Run' in v2 requires quotes for the string/expression
    query := A_Clipboard
    Run("https://www.google.com/search?hl=en&q=" . query)
}


#HotIf WinActive("ahk_group PersonalKanban")
; <A p> => Transition to progress file from kanban.
$!p:: {
	local file
	file := "G:\My Drive\Organization\Progress\Home\Progress (Home).txt"
	Run(file)
}

; Never paste formatting. Otherwise column background colors get screwed up.
$^v:: {
	; The problem with this is now if you paste any multiline cell, it pastes it as multiple cells.
	; clipboard := trim(clipboard, """") ; Remove outer double quotes.
	Send("^+v")

	; Seems like the shift key always gets stuck after this.
	Send("{LShift up}")
}

$^x:: {
	Send("^c")
	Sleep(50)
	Send("{delete}")
	Sleep(50)
	Send("{backspace}")
}
#Hotif


;==============================================================================
; Vim (.ahk files)
; AutoHotkey
;==============================================================================

#HotIf WinActive("ahk_exe mintty.exe")

; AutoHotkey comment bar.
:*:;b::;==============================================================================

; AutoHotkey comment heading.
:*:;h:: {
	; AHK v2 autotrims leading whitespace from strings declared like this.
	header := "
	(
	;==============================================================================
	; | 
	;==============================================================================
	)"

	Send(header)
	Send("{Esc 2}{Up}A{Backspace}")
}
#HotIf


;==============================================================================
; Outlook
;==============================================================================

; Make tapping shift twice do a click.
#HotIf WinActive("Inbox - Jeffrey Anderson - Outlook")
~Shift Up:: {
    if (A_PriorHotkey == A_ThisHotkey && A_TimeSincePriorHotkey < 401) {
        Click()
    }
}
#HotIf

#HotIf WinActive("Junk - Jeffrey Anderson - Outlook")
~Shift Up:: {
    if (A_PriorHotkey == A_ThisHotkey && A_TimeSincePriorHotkey < 401) {
        Click()
    }
}
#HotIf

; Makes <C w> close Outlook.
#HotIf WinActive("ahk_exe olk.exe")
^w:: {
	Send("!{F4}")
}
#HotIf

; CONVERTED

^+h:: {
    MsgBox("Hello, AHK v2!")
}

