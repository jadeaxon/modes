;===============================================================================
; Main
;===============================================================================

; FAIL: AHK v2 syntax highlighting does not work in Vim.
#Requires AutoHotkey v2.0

; FAIL: Makes it so we don't also trigger things like Windows Game Bar.
; InstallKeybdHook()

; Warn about using uninitialized variables, etc.
#Warn
#Warn Unreachable, Off

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

; Are the left Control and Shift keys mapped to sending down/up keystrokes?
; Controlled by a checkbox in the Modes GUI windo (<C-A j>).
OPT_LEFT_HAND_SCROLL := 0

; Speak when hotkeys/hotstrings are triggered?
OPT_SPEAK := 1

; Is the search dialog open in a Google Sheet?
searchDialog := 0

; Context menu position for Slack reminders.
menuPosition := 0

#Include <Library_v2>
#Include <XHotstring>

Run(HOME "\AHK\AutoCorrect2\Core\AutoCorrect2.exe")
Run(HOME "\projects\modes-private\Private_v2.ahk /restart")


;===============================================================================
; Hotstrings
;===============================================================================

; Make the hotstrings case-sensitive.
#Hotstring C

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

; END

;-------------------------------------------------------------------------------
; Regex Hotstrings
;-------------------------------------------------------------------------------

; Typing hello(world) => Hello, world!
XHotstring(":*:hello[(](.*?)[)]", (m, *) => Send("Hello, " m[1] "{!}"))

; FAIL: Z option along with using SendText() causes hotstring to not retrigger itself.
; You have to use the technique below to prevent retriggering.
; You don't need to use X option since its kind of implicit we're executing code.
; This makes it so when you type 'rxhs(<arg>)' it prints out the message.
; The subgroup matches are captured in the m array.
; XHotstring(":Z*:rxhs[(](.*?)[)]", (m, *) => SendText("rxhs() called with arg " m[1]))
XHotstring(":Z*:rxhs[(](.*?)[)]", (m, *) => (
    SendLevel(0), 
    SendEvent("rxhs() called with arg " m[1])
))

; t(2, dishes) => set a timer for a reminder message box to appear in 2m that says "dishes"
XHotstring(":*:t\((\d+), (.+?)\)", (m, *) => set_reminder(Number(m[1]), m[2]))

set_reminder(minutes, what) {
	local millis := minutes * 60 * 1000
	local suffix := (minutes == 1) ? "minute" : "minutes"
	SetTimer(() => (SoundPlay("*64"), MsgBox(what)), -millis)
	ToolTip("Reminder set for " . minutes . " " . suffix)
	SetTimer(RemoveToolTip, -2000)
}


;===============================================================================
; Hotkeys
;===============================================================================

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

^+h:: {
    MsgBox("Hello, AHK v2!")
}

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

; WARNING: Having this on screws up normal typing.
; Alternate scrolling keys so you're not always using your right hand.
; Only enabled when OPT_LEFT_HAND_SCROLL = 1.
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
    SendS("^c")        ; Copy selected text

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

junkMailWindowActive() {
	local active := false
	active := active || WinActive("Junk Email - Jeffrey Anderson - Outlook") 
	active := active || WinActive("Junk - Jeffrey Anderson - Outlook")
	return active
}

emailWindowActive() {
	local active := false
	active := active || WinActive("Inbox - Jeffrey Anderson - Outlook")
	active := active || WinActive("Junk Email - Jeffrey Anderson - Outlook") 
	active := active || WinActive("Junk - Jeffrey Anderson - Outlook")
	return active
}

#HotIf junkMailWindowActive()
d:: {
	SendS("^a")
	SendS("{delete}")
}

RShift & Down:: {
	Send("{Delete}")
}
#HotIf

; Make tapping shift twice do a click.
#HotIf emailWindowActive()
~LShift Up:: {
    if (A_PriorHotkey == A_ThisHotkey && A_TimeSincePriorHotkey < 400) {
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

#HotIf WinActive("YouTube ahk_exe chrome.exe")

; I keep accidentally hitting <C s> to activate this.
/*
^s:: {
    if WinActive("YouTube ahk_exe chrome.exe") {
		toggle_autoscroll()
	}
	else {
		Send("^s")
	}
}
*/

; Autoscroller for YouTube.
^s::
^+s:: 
{
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
    if !ClipWait(2) {
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


;==============================================================================
; Personal Kanban
;==============================================================================

#HotIf WinActive("ahk_group PersonalKanban")
; <C d> => move to done; mark as done; write to progress file
$^d:: {
	local delay := 30
	local delay2 := 60

	location := get_cell_location()

	if (location = "E2") {
		write_to_progress_file()
		return
	}

	if (InStr(location, "A") == 1) {
		; We're in column A. Assume we're in the Recurring sheet.
		mark_recurring_task_done()
		return
	}

	value := get_cell_value(true)

	; Move to top of Done column.
	move_to_cell("E1")
	
	move_to_next_empty_cell()

	; Paste to blank cell.
	A_Clipboard := value
	ClipWait(2)
	SendS("^+v")

	; Go back to original cell.
	move_to_cell(location)

	; Move to first cell below original.
	SendS("{down}")
	
	move_to_next_empty_cell()
	
	; Get cell above empty cell.
	SendS("{Up}")

	value := get_cell_value(true)
	
	; Go back to original cell.
	move_to_cell(location)
	
	; Paste to original cell.
	A_Clipboard := value
	ClipWait(2)
	SendS("^+v")
} ; <C d> hotkey
	
write_to_progress_file() {
	local file	
	; Combined Send for efficiency
	SendS("{Shift down}")
	Loop 6 {
		SendS("{Down}")
	}
	SendS("{Shift up}")
	SendS("^c")
	if !ClipWait(2) {
		return ; Exit if clipboard copy fails
	}
	Sleep(50)
	SendS("{Backspace}")
	Sleep(50)

	; File Path and Run
	file := "G:\My Drive\Organization\Progress\Home\Progress (Home).txt"
	Run(file)
	Sleep(200)
	
	SetTitleMatchMode(2)
	if WinWaitActive("GVIM", , 3) {
		SendS("gg")
		yearShort := A_Year - 2000
		searchYear := (yearShort < 10 ? "0" : "") . yearShort
		
		SendS("/" searchYear "-{Enter}")
		SendS("o^v{Enter}{Esc}")
		Sleep(150)
		SendS("^s")
	}
}

; In Scheduled sheet, set all the dates from current position back to a week from new.
; Defer them all by a week.
$^!d:: {
	local sheet := get_sheet_name()

	if (sheet = "Scheduled") {
		orig_date := get_cell_value()
		new_date := add_days(orig_date, 7)
		A_Clipboard := ""
		A_Clipboard := new_date
		ClipWait(2)
		Loop {
			SendS("^+v")
			Sleep(20)
			SendS("{up}")
			Sleep(20)
			value := get_cell_value()
			
			A_Clipboard := new_date ; since get_cell_value() changes clipboard
			if (value != orig_date) {
				;MsgBox(Format("{} {}", value, orig_date))
				break
			}
			Sleep(20)
		}
	}
}

; Sort by Score descending.
; I end up doing this a lot after marking items as done or at the start of each new day.
; I recorded a macro in Google Sheets that does this when you press <C-A-S 2>.
; This just makes <C s> trigger it instead.
$^s:: {
	local sheet := get_sheet_name()

	location := get_cell_location()
	move_to_cell("A1")
	value := get_cell_value()
	if (value = "Task") {
		sheet := "Recurring"
	}

    if (sheet = "Recurring") {
        ; Trigger the Google Apps Script sort macro
        Send("^+!1")
		; Give time for sort to finish.
		; Else later move_to_cell() call will be undone by what the sort does.
		Sleep(3000)
    }
    else {
        ; Perform the standard save operation
        Send("^s")
    }
	move_to_cell(location)
}

mark_recurring_task_done() {
	;MsgBox("not implemented yet")
	; Not sure why SetKeyDelay() doesn't work but sprinkling Sleep()s everywhere does.
	; It only works when you are in SendEvent mode, which is not the default.
	; SetKeyDelay(50, 50)
	SendS("^b")
	Loop 5 {
		SendS("{right}")
	}
	SendS("^;")
	Loop 5 {
		SendS("{left}")
	}
}

#HotIf


;==============================================================================
; Modes Window
;==============================================================================

; <C-A j> => Jeff's GUI.
; <A-W m> => Modes GUI.
$!#m::
$^!j::
{
    ; Check if GUI already exists by its title "Modes"
    if WinExist("Modes") {
        WinActivate("Modes")
        return
    }

    ; Create a new GUI object
    myGui := Gui(,"Modes")
    myGui.Opt("+LastFound")
    
    ; Setup variables (Using global scope for persistence across GUI runs)
    global OPT_LEFT_HAND_SCROLL := OPT_LEFT_HAND_SCROLL ?? 0
    global OPT_SPEAK := OPT_SPEAK ?? 0

    ; Checkbox 1: Left Scroll [cite: 3, 4]
	cbScroll := myGui.Add("Checkbox", (OPT_LEFT_HAND_SCROLL ? "Checked" : ""), "Enable &scrolling with left control and shift?")
	cbScroll.OnEvent("Click", UpdateOptLeftHandScroll)

    ; Checkbox 2: Speak [cite: 6]
    cbSpeak := myGui.Add("Checkbox", (OPT_SPEAK ? "Checked" : ""), "Spea&k when hotkeys and hotstrings are triggered?")
    cbSpeak.OnEvent("Click", UpdateOptSpeak)

    ; Buttons [cite: 7]
    btnBudget := myGui.Add("Button", "w251", "&Budget")
    btnBudget.OnEvent("Click", Button_Budget)

    btnJiggler := myGui.Add("Button", "w251", "&Mouse Jiggler")
    btnJiggler.OnEvent("Click", (*) => (myGui.Destroy(), Run(A_ScriptDir "\MouseJiggler_v2.ahk")))

    ; Escape key handling [cite: 17]
    myGui.OnEvent("Escape", (guiObj) => guiObj.Destroy())
    myGui.OnEvent("Close", (guiObj) => guiObj.Destroy())

    myGui.Show()
}

UpdateOptSpeak(ctrl, *) {
	global OPT_SPEAK := ctrl.Value
}

UpdateOptLeftHandScroll(ctrl, *) {
    global OPT_LEFT_HAND_SCROLL := ctrl.Value
}


Button_Budget(btn, *) {
    btn.Gui.Destroy()
	local amount
	SetKeyDelay(50, 50) ; 10ms delay between keys, 10ms press duration
    
	amount := A_Clipboard
	amount := Exorcise(amount)
	amount := RegExReplace(amount, "[^\d\.-]")
	amount := Abs(Number(amount))

    if (amount <= 1) {
        MsgBox("You did not copy an amount to the clipboard.", "Error")
        return
    }

    A_Clipboard := ""
    
    ; Path to budget file [cite: 14]
    budgetPath := "G:\My Drive\Organization\Financial\Budget\" A_YYYY "\" A_YYYY " Budget.txt"
    
    if FileExist(budgetPath) {
        Run(budgetPath)
        if WinWaitActive(A_YYYY " Budget ahk_exe gvim.exe",, 5) {
            ; Vim commands [cite: 15]
            SendS("{esc}{esc}gg/NEXT{enter}{up}")
            Sleep(100)
			; Sends('"{+}yW') ; Copy line to clipboard in Vim
			SendS('"')
			SendS("{+}")
			SendS("y")
			SendS("W")
            Sleep(100)

            if ClipWait(2) {
				remBudget := A_Clipboard
				remBudget := Exorcise(remBudget)
				remBudget := RegExReplace(remBudget, "[^\d\.-]")
				remBudget := Number(remBudget)
                newRem := Round(remBudget - amount, 2)
                
                ; Format output 
				if (newRem >= 0)
					out := "$" . newRem
				else 
					out := "-$" . Abs(newRem)
                ; Commify logic
                out := RegExReplace(out, "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,")
                
                formattedAmt := Format("{:.2f}", amount)
                SendS("o" out "{space}-$" formattedAmt "{space}")
            } ; wait for clipboard
        } ; gVim active
    } ; budget file exists
} ; Button_Budget()


; Make <Enter> also close the Modes window.
#HotIf WinActive("Modes")
Enter:: {
    if (activeHwnd := WinActive("A")) {
        guiObj := GuiFromHwnd(activeHwnd)
        guiObj.Destroy()
    }
}
#HotIf


;===============================================================================
; Submodes
;===============================================================================

; <W d> => Debug mode.
$#d:: {
    SoundPlay("Sounds\buzzing_bug.wav")
	ToolTip("Debug mode ON")
	SetTimer(RemoveToolTip, -2000)
    Run("Debug_v2.ahk")
}

; FAIL: <A-W r>: conflicts with Windows Game Bar.
; <C r> => Recurring Tasks mode 
#HotIf WinActive("ahk_group PersonalKanban")
$^r:: {
	ToolTip("Recurring Tasks mode ON")
	SetTimer(RemoveToolTip, -2000)
	Run("Recurring_Tasks_v2.ahk")
}

$^m:: {
	ToolTip("Kanban mode ON")
	SetTimer(RemoveToolTip, -2000)
	Run("Kanban_v2.ahk")

}
#HotIf

; #UseHook false
LControl & Escape:: {
    SoundPlay("*65") ; *65 is a system sound
	speak("Reloading Modes")
    Reload()

    ; This code only runs if Reload fails
	; Pointless. A system dialog comes up if there are reload problems.
	/*
    Sleep(1000)
    result := MsgBox("Script reloaded unsuccessful, open it for editing?",, "Y/N/C")
    if (result = "Yes") {
        Edit()
    }
	*/
}

