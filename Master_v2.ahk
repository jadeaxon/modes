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

; Insert a Unicode bullet symbol immediately.
; Use Windows Charater Map advanced view to search for these (or google them).
:*:uBullet::{U+2022}
:*:uBul::{U+2022}
:*:uDot::{U+2022}
:*:uDegrees::{U+00B0}
:*:uAry::{U+00BA} ; Ordinal indicator: primary, secondary, etc.
:*:uEuros::{U+20AC}
:*:uPlusOrMinus::{U+00B1}
:*:uPlusMinus::{U+00B1}
:*:uInfinity::{U+221E}
:*:uIntersection::{U+2229}
:*:uUnion::{U+222A}
:*:uEnDash::{U+2013}
:*:uEmDash::{U+2014}
:*:uCheck::{U+2713}
:*:uSquared::{U+00B2}
:*:uCubed::{U+00B3}

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

; This hotstring replaces "<date>" with the current date and time.
:*:<date>:: {
    ; FormatTime now returns the string directly as a function
    monthDay := FormatTime(, "d")
    month    := FormatTime(, "MMMM")
    weekDay  := FormatTime(, "dddd")
    year     := FormatTime(, "yyyy")

    ; Call your ordinal function (make sure it's converted to v2 as well)
    monthDay := Ordinal(monthDay)

    ; Construct the string using standard expression syntax (concatenation)
    output := weekDay ", " month " " monthDay ", " year

    Send(output)
}

; 9/11/2011 9:30 AM
:*:<ts>:: {
    output := FormatTime(, "M/d/yyyy h:mm tt")
    Send(output)
}

; 03/22/2O12
:*:<mdy>:: {
    output := FormatTime(, "MM/dd/yyyy ")
    Send(output)
}

; 2018-08-12
:*:ymd`s::
:*:<ymd->::
{
	output := FormatTime(, "yyyy-MM-dd ")
    Send(output)
}

; 2018-08-12: 
:*:ymd`::: {
	output := FormatTime(, "yyyy-MM-dd: ")
    Send(output)
}

; 2018/08/12
:*:<ymd>:: {
	output := FormatTime(, "yyyy/MM/dd ")
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

; Make it so Esc dismisses the search dialog if it is present.
$^f:: {
	global searchDialog
	searchDialog := 1
	Send("^f")
}

Esc:: {
	global searchDialog
	if (searchDialog) {
		Send("^f")
		Send("{tab}{tab}")
		Send("{enter}")
		searchDialog := 0
	}
}
#Hotif

; <C-w> in Sumatra PDF Reader closes the app.
#HotIf WinActive("ahk_class SUMATRA_PDF_FRAME")
$^w:: {
    WinClose("A")
}
#Hotif

; Make <Ctrl + W> close Cygwin/mintty windows (so your tabbed-browsing moves work everywhere).
#HotIf WinActive("ahk_class mintty")
$^w:: {
    WinClose("A")
}
#Hotif

; Make <Ctrl + W> close AHK help windows (so your tabbed-browsing moves work everywhere).
#HotIf WinActive("ahk_class HH Parent")
$^w:: {
    WinClose("A")
}
#Hotif

; Make <Ctrl + W> close Preview windows (so your tabbed-browsing moves work everywhere).
#HotIf WinActive("ahk_class Photo_Lightweight_Viewer")
$^w:: {
    WinClose("A")
}
#Hotif

; <C w> => minimize window in KeePaas.
; By default, it closes the open file which is never what I want to do.
#HotIf WinActive("ahk_exe KeePass.exe")
$^w:: {
	WinMinimize("A")
}
#Hotif

; <C-A p> => Speak (pronounce) what's on the clipboard.
^!p:: {
    global OPT_SPEAK
    saved := OPT_SPEAK
    OPT_SPEAK := 1
    speak(A_Clipboard)
    OPT_SPEAK := saved
}

; <W p> => Copy a relative MouseMove(x, y) at current mouse location.
; <W p> usually opens a screen to let you select a projector, which is useless to me.
$#p:: {
	local x
	local y
    MouseGetPos(&x, &y)
    A_Clipboard := Format("MouseMove({}, {})", x, y)
}


; <C-A w> => Show info for all windows.
$^!w:: {
    ; WinGetList returns a proper Array of HWNDs (Unique IDs)
    ids := WinGetList(,, "Program Manager")

    for this_id in ids {
        ; Activate the window using the ID
        try {
            WinActivate(this_id)
            this_class := WinGetClass(this_id)
            this_title := WinGetTitle(this_id)

            ; MsgBox syntax: MsgBox(Text, Title, Options)
            ; Option 5 is 'Abort/Retry/Ignore' in v1, but 'Retry/Cancel' or 'Yes/No'
            ; is handled differently in v2. We'll use "Yes/No" (Option 4).
            result := MsgBox(
				"Visiting All Windows`n" A_Index " of " ids.Length "`nahk_id " this_id .
				"`nahk_class " this_class "`n" this_title "`n`nContinue?",, 4
			)

            if (result = "No")
                break
        } 
		catch {
            ; Skip windows that might have closed or are restricted (like some system trays)
            continue
        }
    } ; next id
}

; <W-A y> => Open AHK Window Spy.
#!y:: {
    spyPath := A_ProgramFiles "\AutoHotkey\WindowSpy.ahk"
    
    if FileExist(spyPath) {
        Run(spyPath)
    } 
	else {
        MsgBox("Window Spy not found at:`n" spyPath)
    }
}

; <C w> => Close AHK Window Spy.
#HotIf WinActive("Window Spy ahk_class AutoHotkeyGUI")
^w:: {
    WinClose("A")
}
#HotIf

; Make the Windows 11 settings window close via <C w>.
#HotIf WinActive("Settings ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
$^w:: {
	WinClose("A")
}
#HotIf

; END

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

emailWindowActive() {
	local active
	active := WinActive("Inbox - Jeffrey Anderson - Outlook")
	active := active || WinActive("Junk Email - Jeffrey Anderson - Outlook") 
	active := active || WinActive("Junk - Jeffrey Anderson - Outlook")
	return active
}

; Make tapping shift twice do a click.
#HotIf emailWindowActive()
~LShift Up:: {
    if (A_PriorHotkey == A_ThisHotkey && A_TimeSincePriorHotkey < 400) {
        Click()
    }
}

RShift & Down:: {
	Send("{Delete}")
}

#HotIf

; Makes <C w> close Outlook.
#HotIf WinActive("ahk_exe olk.exe")
^w:: {
	Send("!{F4}")
}
#HotIf


;==============================================================================
; Firefox
;==============================================================================

;-------------------------------------------------------------------------------
; Make <Ctrl + T> open a new Google tab in Firefox (instead of a blank).
; Firefox is brain dead in this regard.  Why would you want to open a blank tab???
; Bloody brilliant.  This works like a charm.
;
; TIP: <Ctrl + Shift + T> resurrects the last tab you (accidentally) closed.
#HotIf WinActive("ahk_exe firefox.exe")
$^t:: {
    ; Create the new tab.
    Send("^t")
    ; Go to the address bar.
    Send("^l")
    ; Type in Google address.
    Send("www.google.com{Enter}")
}

; Adds current URL to Bookmarks Toolbar|Now bookmarks.
$^d:: {
	Send("^d") ; Open save new bookmark dialog.
	Sleep(500)
	Send("{Tab}{Tab}{Enter}") ; Open dialog to choose folder.
	Sleep(200)
	Send("{left}{right}n") ; Choose bookmarks toolbar N folder.
	Sleep(200)
	Send("!{Enter}") ; Submit dialog.
}

; Let's try having ;; delete the bookmark.
:*:;;:: {
	Send("{AppsKey}d")
}
#HotIf


;==============================================================================
; Chrome
;==============================================================================

#HotIf WinActive("ahk_exe chrome.exe")

; I keep accidentally hitting <C s> to activate this.
^s:: {
    if WinActive("YouTube ahk_exe chrome.exe") {
		toggle_autoscroll()
	}
	else {
		Send("^s")
	}
}

; Autoscroller mainly for YouTube.
^+s:: {
	toggle_autoscroll()
}
#HotIf

autoscroll := false
toggle_autoscroll() {
	global autoscroll
    global mouse_x_start, mouse_y_start ; Declare if these are used elsewhere

    ; Toggle the variable
	autoscroll := !autoscroll

    if (autoscroll) {
        ; MouseGetPos uses OutputVar references (&) in v2
        MouseGetPos(&mouse_x_start, &mouse_y_start)

        ; SetTimer uses a function name (or object) without quotes
        SetTimer(SendDownKey, 750)
        ToolTip("Autoscroll ON")
        SetTimer(RemoveToolTip, -2000)
    }
    else {
        ; Stop the timer
        SetTimer(SendDownKey, 0) ; '0' or 'Off' stops the timer in v2
        ToolTip("Autoscroll OFF: toggled by hotkey")
        SetTimer(RemoveToolTip, -2000)
    }
}

SendDownKey() {
    ; Access the global variables from the main script/toggle function
    global autoscroll, mouse_x_start, mouse_y_start
	local mouse_has_moved

    ; Check current position using VarRef (&)
    MouseGetPos(&mouse_x, &mouse_y)

    ; Calculate distance moved using standard expressions
	mouse_has_moved := (Abs(mouse_x - mouse_x_start) > 10 || Abs(mouse_y - mouse_y_start) > 10)
    if (mouse_has_moved) {
        autoscroll := false
        SetTimer(SendDownKey, 0) ; '0' stops the timer
        ToolTip("Autoscroll OFF: mouse moved")
        SetTimer(RemoveToolTip, -2000)
        return
    }

    ; Safety check: Only send the key if Chrome is active
    if WinActive("ahk_exe chrome.exe") {
        Send("{Down}")
    }
    else {
        ; Stop if you switch away from Chrome
        autoscroll := false
        SetTimer(SendDownKey, 0)
        ToolTip("Autoscroll OFF: changed windows")
        SetTimer(RemoveToolTip, -2000)
    }
}

RemoveToolTip() => ToolTip()

; Move through YouTube videos using left hand.
#HotIf (WinActive("YouTube ahk_exe chrome.exe") && IsMouseInVideoZone())
a::Send("{Left}")
o::Send("{Right}")
$^l:: {
    MouseGetPos(&mouseX, &mouseY)
	MouseMove(mouseX, 130) ; Zenbook address bar location
	Send("^l") ; move keyboard focus to address bar
}
#HotIf

IsMouseInVideoZone() {
	local mouseY
    static threshold := 0.30 ; Top 30% of screen is "Safe Zone" for Address Bar
    MouseGetPos(, &mouseY)
    return (mouseY > (A_ScreenHeight * threshold))
}


;==============================================================================
; Windows Explorer
;==============================================================================

; Open command prompt at current folder in Explorer.
; <Ctrl + Alt + c> in Windows Explorer.
#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass")
$^!c:: {
    ClipSaved := ClipboardAll()

    A_Clipboard := "" ; Clear the clipboard
    Send("!d")        ; Focus address bar
    Sleep(50)         ; Slightly longer sleep for reliability
    Send("^c")        ; Copy path

    ; ClipWait(timeout) returns 0 if it times out
    if !ClipWait(3) {
        MsgBox("The attempt to copy text onto the clipboard failed.")
        return
    }

    Run('cmd /K "cd /d "' A_Clipboard '"')

    ; Restore the previous clipboard content
    A_Clipboard := ClipSaved
    ClipSaved := "" ; Clear the buffer variable
}

; Closes all Explorer windows when <A-S F5> pressed.
!+F4:: {
	if ( WinExist("ahk_group ExplorerGroup") ) {
		WinClose("ahk_group ExplorerGroup")
	}
}

; <A d> => new directory in Windows Explorer.
$!d:: {
	Send("^+n")
}

/*
Used to be easy in Windows 10.
$!t:: {
	Send("+{F10}wt")
}
*/

; <A t> => new text file in Windows Explorer.
!t:: {
    ; Get the active Explorer window object
    hwnd := WinExist("A")
    activeTab := ""

    try {
        shellApp := ComObject("Shell.Application")
        for window in shellApp.Windows {
            if (window.hwnd == hwnd) {
                ; Get the folder path from the window object
                activeTab := window.Document.Folder.Self.Path
                break
            }
        }

        if (activeTab != "") {
            ; Define the default name
            filePath := activeTab "\New Text Document.txt"

            ; Handle name collisions (New Text Document (2).txt, etc.)
            count := 2
            while FileExist(filePath) {
                filePath := activeTab "\New Text Document (" count ").txt"
                count++
            }

            ; Create the file
            FileAppend("", filePath)

            ; Tell Explorer to refresh and show the file
            Send("{F5}")

            ; Optional: Automatically start renaming the new file
            ; We wait for the UI to update, then type the name to select it
            Sleep(300)
            SplitPath(filePath, &fileName)
            Send(fileName)
            Sleep(100)
            Send("{F2}")
        }
    } 
	catch as e {
        ; Silently fail or log to your strategy status
    }
} ; <A t>

#HotIf


; CONVERTED

^+h:: {
    MsgBox("Hello, AHK v2!")
}

