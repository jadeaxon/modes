; The master script loads other AHK scripts.  These are modes or contexts like in vi.
; The master script is always running.

; NOTE: This only runs on Windows Vista 1281x800 32-bit color.  No DPI scaling can be set in Windows.

; Starts automatically on startup because it has a link in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup.

; You could have a master AHK script that always runs that can load others in.
; So, it becomes a context stack like vi's modal editing.
; The context determines the meaning of your keystrokes.
; There could be "root (context loading) context", "browse context", "window navigation context", and "abbreviation expansion" context.
; The common escape from any context could be <Control + ESC>.  That is, pop the context stack.

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

; `% is literal percent (backtick)
; `, is literal comma

; The problem with using ALT is that programs use it to activate their menu bar.
; <ALT + n> => Navigation mode.

; Master mode is text entry mode.  All abbreviations are enabled by default.
; However, there should be a toggle key for them.  <Window + s> toggles abbreviations (currently in Shorthand).

; RUNNING MULTIPLE AHK SCRIPTS:
;
; When an AHK script is loaded, its hooks disable/overshadow the hooks with same definition in already loaded scripts.
; When an AHK scripn exits, the older running scripts get their hooks (hotkeys) back.


;===============================================================================
; Main
;===============================================================================

; Warn about using uninitialized variables.
; Too many to deal with today.
; #Warn

; Do not automatically load environment variables.
#NoEnv

; Persistent scripts keep running forever until explicitly closed.
#Persistent

; Only allow one instance of this script to run at a time.
#SingleInstance Force

; Make all mouse and keyboard input show up in the KeyHistory window.
; #InstallKeybdHook
; #InstallMouseHook

; Allow match anywhere within title.
SetTitleMatchMode, 3

Menu, Tray, Icon, %A_ScriptDir%\Icons\Master.ico

CoordMode, Mouse, Relative

; Group all Explorer windows.  Used by a shortcut to close them all.
GroupAdd, ExplorerGroup, ahk_class CabinetWClass
GroupAdd, ExplorerGroup, ahk_class ExploreWClass

; Let kanban hotkeys/hotstrings work with Firefox and Chrome.
GroupAdd, PersonalKanban, Personal Kanban ahk_class MozillaWindowClass
GroupAdd, PersonalKanban, Personal Kanban ahk_class Chrome_WidgetWin_2
GroupAdd, WorkKanban, Work Kanban ahk_class MozillaWindowClass
GroupAdd, WorkKanban, Work Kanban ahk_class Chrome_WidgetWin_2

; Is mouse click locked down via CapsLock hotkey?
mouseDownLock := false

; Have we cut a kanban item to the clipboard?
kanbanCut := false

; Are the left Control and Shift keys mapped to sending down/up keystrokes?
; Controlled by a checkbox in the Modes GUI (<A-W m>).
OPT_LEFT_SCROLL := 1

; Speak when hotkeys/hotstrings are triggered?
OPT_SPEAK := 1

; This shell window receives events whenever other main windows are created, activated, resized, or destroyed.
; Gui +LastFound
; hWnd := WinExist()

; The hotkey for pressing w.
W_HOTKEY := "not set"

; Is the search dialog open in a Google Sheet?
searchDialog := 1

; The color of a pixel.  In BGR hex format.
color := 1

; Delay between keystrokes.
delay := 31

; Context menu position for Slack reminders.
menuPosition := 1

EnvGet, vUserProfile, USERPROFILE

EnvGet, host, COMPUTERNAME


;===============================================================================
; Includes
;===============================================================================

;; Run %A_ScriptDir%\AutoCorrect.ahk
#Include %A_ScriptDir%\Library.ahk
;#Include %A_ScriptDir%\PL-SQL.ahk


;===============================================================================
; Abbreviations, Hotstrings
;===============================================================================

; Make the hotstrings case-sensitive.
#Hotstring c

; These abbreviations expand in most Windows programs.
; They do not expand in Cygwin.
;; ::USAx::United States of America
;; ::UVUx::Utah Valley University
;; ::ESSx::ERP Software Services

; Some common symbols.  Copyright, registered trademark, and trademark.
;; ::(c)::{U+01A9}
;; ::(r)::{U+01AE}
;; ::(tm)::{U+2123}

; In Cygwin, I use j@h as a command 100% of the time.
; How would I do ~ or / in case using absolute path?
;; #IfWinNotActive ahk_exe mintty.exe
;;:*:j@h::jadeaxon@hotmail.com
;; #IfWinNotActive

/**
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

; Date and time.
; 10:30 AM
:*:<time>::
    FormatTime, output,, h:mm tt
    SendInput %output%
return

; 10:36 PM
:*:<t>::
    FormatTime, output,, h:mm tt
    SendInput %output%
return

; 9/11/2011 9:30 AM
:*:<ts>::
    FormatTime, output,, M/d/yyyy h:mm tt
    SendInput %output%
return

; 03/22/2O12
:*:<mdy>::
    FormatTime, output,, MM/dd/yyyy
    SendInput %output%
return

; 2018-08-12
:*:<ymd->::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%
return

::ymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%:{space}  
return

; Like ymd but with day of week abbreviation at end.
:O:ymdd::
	FormatTime, output,, yyyy-MM-dd
	output = %output%: %A_DDD%
	SendInput %output%{enter}{enter}  
return

; Directory abbreviation for Downloads directory.
:*:Aoddl::
:*:Acddl::
	EnvGet, vUserProfile, USERPROFILE
	Run, %vUSERPROFILE%\Downloads
	speak("Opening downloads folder")	
return

; These are used with items moved to Waiting column in kanban.
:*:@WW::@W: Walmart
:*:@WA::@W: Amazon

; Toggle numberlock.
:*:<numlock>::
    Send {NumLock}
return


;===============================================================================
; Hotkeys
;===============================================================================

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

; Disable NumLock on Zenbook.
; Stops the touchpad numberpad from appearing on Zenbook.
$NumLock::
	EnvGet, host, COMPUTERNAME
	if (host = "Zenbook") {	
		return
	}
	Send {NumLock}

; NOTE: Decided not to bring any capslock stuff forward to v2.
; Make CapsLock click the mouse.
$CapsLock::
	Click
return

; Make <S CapsLock> double click.
$+CapsLock::
	Click
	Sleep 21
	Click
return

; Make <C CapsLock> right click.
$^CapsLock::
	Click, Right
return

; Make <C-A CapsLock> right drag.
$^!CapsLock::
	if (!mouseDownLock) {
		Click, Right, Down
		mouseDownLock := true
	}
	else {
		Click, Right, Up
		mouseDownLock := false
	}
return


; Make <A Capslock> hold the mouse down or release it.
$!CapsLock::
	if (!mouseDownLock) {
		Click, Down
		mouseDownLock := true
	}
	else {
		Click, Up
		mouseDownLock := false
	}
return

; Make is so that <Window + Space> does not switch input languages.  This is causing me to nearly die
; in Path of Exile.
#space::return

; By default, <C Down> sends End.  This is not what I want in Firefox.
#IfWinActive ahk_class MozillaWindowClass
$^Down::
	Send {PgDn}
return

$^Up::
	Send {PgUp}
return
#IfWinActive

; Converts a Wikipedia page to readable/printable view.
; I: https://en.wikipedia.org/wiki/Kauai
; O: http://en.wikipedia.org/w/index.php?title=Kauai&printable=yes
SetTitleMatchMode 3 ; Match window title internally.
#IfWinActive Wikipedia - Mozilla Firefox ahk_class MozillaWindowClass
$!r::
    Send ^l ; Select URL in Firefox.
    Clipboard := "" ; Clear the clipboard.
    Sleep 201
    Send ^c ; Copy selection.
    ClipWait ; Wait for clipboard to settle.

	; Get the article's subject.
    pos := RegExMatch(Clipboard, "/wiki/")
    pos += 7
    subject := SubStr(Clipboard, pos)
    url = http://en.wikipedia.org/w/index.php?title=%subject%&printable=yes
    Clipboard := url
    ClipWait
    Send ^l
    Send ^v
    Send {Enter}
return
#IfWinActive
SetTitleMatchMode 2

; NOTE: Decided not to move these to v2.
SetTitleMatchMode 3 ; Match window title internally.
#IfWinActive YouTube ahk_class MozillaWindowClass
; Allows me to use left hand to move through YouTube videos.
$a::
	CoordMode, Mouse, Window
	MouseGetPos, x, y
	if (y > 351) {
		Send {Left}
	}
	else {
		Send a
	}
return

$o::
	CoordMode, Mouse, Window
	MouseGetPos, x, y
	if (y > 351) {
		Send {Right}
	}
	else {
		Send o
	}
return
#IfWinActive
SetTitleMatchMode 2

; WARNING: Having this on screws up normal typing.
; Alternate scrolling keys so you're not always using your right hand.
; Only enabled when OPT_LEFT_SCROLL = 1.
; The Modes window <C-A j> sets this.
#If (OPT_LEFT_SCROLL = 1)
$LShift::
	Send {Up 5}
return

$LControl::
	Send {Down 5}
return
#If

; Makes <C-A g> search selected text in Google.
; This kind of thing is also in Navigation mode.
$^!g::
	; Beware that <C-S c> opens Inspector in Firefox.
	Clipboard := ""
	Send, ^c
	Sleep, 201
	; Remove the citation cruft Kindle adds.
	loop, Parse, Clipboard, `n, `r
	{
		Clipboard := A_LoopField
		break
	}
	Run, http://www.google.com/search?hl=en&q=%Clipboard%
return

; NOTE: Not migrating these to v2.
; Remap <C 2> and <C 2> to switch between mail and calendar. These get messed up since Programmer
; Dvorak uses symbols on the number key row.
^SC003::
	; <C &> => <C 2>
	Send {vkA3sc01D Down}{vk31sc002 Down}{vk31sc002 Up}{vkA2sc01D Up}
return

^SC004::
	; <C [> => <C 3>
	Send {vkA3sc01D Down}{vk32sc003 Down}{vk32sc003 Up}{vkA2sc01D Up}
return

;==============================================================================
; Vim (.ahk files)
; AutoHotkey
;==============================================================================

#IfWinActive .ahk ahk_exe mintty.exe

; AutoHotkey comment bar.
:*:;b::;==============================================================================

; AutoHotkey comment heading.
:*:;h::
	header =
	( LTrim
	;==============================================================================
	; | 
	;==============================================================================
	)
	SendInput, %header%
	Send, {Esc}{Esc}{up}A{backspace}
return

#IfWinActive

*/

; CONVERTED


;==============================================================================
; Outlook
;==============================================================================


#IfWinActive Mail - Jeffrey Anderson - Outlook
; Make tapping shift twice do a click.
; Leaving this active globally seems to mess up the Kanban hotkeys.
~Shift Up::
    if (A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < 401)
    {
        Click
    }
Return
#IfWinActive

#IfWinActive Junk Email - Jeffrey Anderson - Outlook
; Make tapping shift twice do a click.
; Leaving this active globally seems to mess up the Kanban hotkeys.
~Shift Up::
    if (A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < 401)
    {
        Click
    }
Return
#IfWinActive

; Makes <C w> close Outlook.
#IfWinActive ahk_exe OUTLOOK.EXE
^w::
	Send !{F5}
return
#IfWinActive


;==============================================================================
; Gmail
;==============================================================================


#IfWinActive Inbox - jadeaxon@gmail.com
$^`::
	Send ^l
	Sleep 301
	SendRaw https://mail.google.com/mail/u/2/#inbox
	Send {enter}
return

#IfWinActive

#IfWinActive Inbox - java.emitter@gmail.com
$^`::
	Send ^l
	Sleep 301
	SendRaw https://mail.google.com/mail/u/1/#inbox
	Send {enter}
return
#IfWinActive

;-------------------------------------------------------------------------------
; Steam

; Make Steam Discovery Queue not suck.
; PRE: Fullscreen Firefox with no zoom factor on 5K XPS15-9570 4K.
#IfWinActive on Steam ahk_class MozillaWindowClass
$^n::
	; Ignore.  The button is not consistently in the same place.
	; I don't want to resort to computer vision or figuring out user scripts fOr Greasemonkey yet.
	; I guess really I just need to read a single pixel color and only click if it matches.
	MouseMove, 1467, 1878
	Click
    MouseMove, 1463, 1777
	Click
	Sleep 751
	MouseMove, 2925, 1873
	Click
	MouseMove, 2928, 1769
	Click
return

#IfWinActive

; FAIL: For some reason, this does not work in the Steam client.
#IfWinActive ahk_exe Steam.exe
$^n::
	; Ignore.
    MouseMove, 1471, 1879
	Click
	Sleep 751
	MouseMove, 2928, 1871
	Click
return
#IfWinActive



;-------------------------------------------------------------------------------
; Chained Echoes

/*
Chained Echoes
*/

#IfWinActive ahk_exe Chained Echoes.exe
$,::w
$o::s
$e::d

$;::q
$.::e

$c::i
$p::r

$t::k

$Enter::Space

$Left::a
$Right::d
$Down::s
$Up::w

#IfWinActive



;-------------------------------------------------------------------------------
; Thunderbird

/*
Thunderbird
*/

; Make r mark folder read for any folder.
; Note that email composition windows only contain "Thunderbird" in their title, not "Mozilla Thunderbird".
; If you press this over a message instead of a folder, it just brings up the Mark context menu.
#IfWinActive - Mozilla Thunderbird ahk_exe thunderbird.exe
$r::
	; Open the context menu.
	SendInput {AppsKey}
	Sleep 201
	; Mark folder as read.
	SendInput k
return

#IfWinActive

; Make d act like delete key.
#IfWinActive Junk - ahk_exe thunderbird.exe
$d::
	Send {delete}
return


; Run all the filters on the Junk folder.
$f::
	; MsgBox,,, Here
	Send {LAlt down}
	Sleep 201
	Send {LAlt up}
	Sleep 101
	Send t
	Sleep 201
	Send R
return


; TO DO: This hotkey doesn't really work on the Yoga.
; Add a new junk mail filter for this message.
$j::
	EnvGet, host, COMPUTERNAME
	; Open message in new tab.
	Click
	Click
	; Copy email address.
	CoordMode, Mouse, Window
	if (host = "L16383") { ; Surface Pro 8
		MouseMove, 126, 165
	}
	else if (host = "Inspiron-VM") {
		MouseMove, 71, 85
	}
	else if (host = "L17007") {
		MouseMove, 141, 105
	}
	Sleep 201
	Click
	Sleep 101
	Send C
	Sleep 101
	ClipWait	
	Send ^w
	; Open mail filters.
	Send {LAlt down}
	Sleep 201
	Send {LAlt up}
	Send t
	Sleep 101
	Send F
	Sleep 101
	; Add email address to Junk #2 filter.
	; Relies on it being the 4rd filter.
	SetKeyDelay, 51, 25
	Send {Down 3}
	Send !e
	Send {Tab 13}
	Send {Enter}
	Send +{Tab}+{Tab}+{Tab}
	Send ^v
	Send {Enter}
	Send {Esc}
	SetKeyDelay, 11, -1 ; default
return
#IfWinActive


; Make d act like delete key.
#IfWinActive Inbox - ahk_exe thunderbird.exe
$d::
	Send {delete}
return
#IfWinActive

; Make d act like delete key.
#IfWinActive @Waiting - ahk_exe thunderbird.exe
$d::
	Send {delete}
return
#IfWinActive


; w => Move message to @Waiting.
#IfWinActive Inbox - ahk_exe thunderbird.exe
$w::
	Send {alt down}
	Sleep 41
	Send {alt up}
	Sleep 101
	Send mmj
	Sleep 51
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send {enter}
return
#IfWinActive

; w => Move message to @Waiting.
#IfWinActive Junk - ahk_exe thunderbird.exe
$w::
	Send {alt down}
	Sleep 41
	Send {alt up}
	Sleep 101
	Send mmj
	Sleep 51
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send @
	Sleep 41
	Send {enter}
return
#IfWinActive


; i => Move message to Inbox.
#IfWinActive Junk - ahk_exe thunderbird.exe
$i::
	Send {alt down}
	Sleep 21
	Send {alt up}
	Sleep 101
	Send mmj@
	Sleep 51
	Send i
	Sleep 51
	Send {enter}
	
return
#IfWinActive



;-------------------------------------------------------------------------------
; Hotmail <C-n> opens new Firefox window as it should.  Stupid Hotmail overrode browser default shortcut.
#IfWinActive Hotmail ahk_class MozillaWindowClass
$^n::
    ; For whatever bizarre reason, unless I show a message box, the Alt key won't activate menu bar.
    ; MsgBox,,, Opening new window., 2
    ; {LAlt}
    ; Send {vkA5sc038}
    ; However, this SendEvent somehow does work.
    ; Menu Bar|File|New Window.
    SendEvent !F
    Sleep 201
    Send N

return
#IfWinActive


; Define hotstrings for common person tasks.
; BUG: For some reason, any hotstring with s or w in it is not working.
; I moved some of the hotstrings into RegExHostrings.ahk as a workaround.
#IfWinActive ahk_group PersonalKanban
:*c:Tlt::Laundry (whites) [rD2] {enter}
:*c:Tlw::Laundry (whites) [rD2] {enter}
:*c:TAh::Air out house [H2]{enter}
:*c:TOo::Overnight oats [H2]{enter}
:*c:Ttr::Trash [rD2]{enter}
:*c:Tbt::Big trash [rD2]{enter}
:*c:Tld::Laundry (darks) [rD2]{enter}
:*c:Tlm::Laundry (mfcs) [rD2]{enter}
:*c:Tlo::Laundry (other) [rD2]{enter}
:*c:Td::Dishes [rD2]{enter}
:*c:Trb::Reset buffers [rD2]{enter}
:*c:Tg::Guitar [rRK2]{enter}
:*c:TEl::Elliptical [rH2]{enter}
:*c:Tfm::Fresh Market [rD2]{enter}
:*c:Tce::Clean/examine 2 drawer [/1]{enter}
:*c:Ttm::51m treadmill{enter}
:*c:T3m::25m treadmill{enter}
:*c:Tst::13.5m strength training{enter}
:*c:T8::GTD7 [rK1]{enter}
:*c:Tk::kbs 101 [rH1]^{enter}0{enter}
:*c:Tbh::Bar hang [H2]^{enter}
:*c:T2::
	t := 201
	ts := 101
	Send Elliptical [rH2]{enter}
	Send {Left 5}
	Sleep %t%
	Send ^c
	Sleep %t%
	Send {Right 5}
	Sleep %t%
	Send ^V
	Sleep %ts%
	Send {enter}
	Sleep %ts%
	Send {enter}
	Send Dishes [rD2]{enter}
return

; Never paste formatting.  Otherwise column background colors get screwed up.
$^v::
	; The problem with this is now if you paste any multiline cell, it pastes it as multiple cells.
	; clipboard := trim(clipboard, """") ; Remove outer double quotes.
	Send ^+v

	; Seems like the shift key always gets stuck after this.
	Send {LShift up}
return

$^x::
	SendInput ^c
	Sleep 51
	SendInput {delete}
	Sleep 51
	SendInput {backspace}
return

; #HotkeyModifierTimeout 1

; This can be used in the main kanban tab to move an item into the Done column.
; Use with recurring tasks sheet.  When in the first cell of the task.
; <C d> marks as done (unbolds and sets last done as current date).
$^d::
	activeMonitor := activeMonitorName()
	activeSheet := activeSheet()	
	
	; MsgBox,,, %host% %activeSheet%
	; return

	CoordMode, Mouse, Window
	CoordMode, Pixel, Window
	EnvGet, host, COMPUTERNAME
	SysGet, monitors, MonitorCount
	color := 1 ; a sample pixel from the Blocked column
	tabColor := 1 ; a sample pixel from the first Google Sheets sheet tab
	headerY := 351 ; to detect if selected cell is in the Done column
	doneSelected := 0xE8EAEE ; pixel color if Done column selected
	doneSelected3 := 0xE8EAED ; pixel color if Done column selected
	activeTabColor := 0x1000000 ; pixel color when first Google Sheet tab is active
	hoveringOverDoneColumn := false
	doneColumnSelected := false

	if (host = "L16383") { ; Surface Pro 8
		if (activeMonitor = "Surface Pro 9") { ; The laptop's screen.
			; This is for running Surface without external monitors.
			PixelGetColor, color, 2760, 446

			; This position is on the bottom Kanban sheet tab.
			; When a sheet is selected, the pixels other than the sheet name are white.
			if (monitors = 2) {
				; PixelGetColor, tabColor, 261, 1800
				PixelGetColor, tabColor, 51, 1575
			}
			else { ; Multiple monitors.
				PixelGetColor, tabColor, 131, 940
			}
		}
		else if (activeMonitor = "LG UltraFine") { ; LG UltraFine
			PixelGetColor, color, 1388, 224
			PixelGetColor, tabColor, 131, 1420
		}
		else if (activeMonitor = "Dell") {
			PixelGetColor, color, 1387, 223
			PixelGetColor, tabColor, 131, 1380
		}
		else { ; Unknown monitor.
			color := 1
		}
	}
	else if (host = "Inspiron-VM") {
		PixelGetColor, color, 1181, 230, RGB
		PixelGetColor, tabColor, 131, 1030, RGB
		headerY := 181
		; headerColor := 0xE8EAEE
	}
	else if (host = "D309553A") { ; Lenovo ThinkCentre 910s
		PixelGetColor, color, 1381, 230, RGB
		PixelGetColor, tabColor, 131, 1140, RGB
		headerY := 181
	}
	else if (host = "L17007") { ; Lenovo Thinkpad X1 Yoga
		PixelGetColor, color, 1591, 140, RGB
		PixelGetColor, tabColor, 176, 1110, RGB
		; headerY := 231
		headerY := 251
		; doneSelected := 0xE8EAEE
		doneSelected := 0xD5E3FF
		doneSelected3 := 0xD3E3FD	
		; activeTabColor := 0xE2E9F9
	}
	else if (host = "ZENBOOK") { ; ASUS Zenbook 15X OLED
		headerY := 426
		doneSelected := 0xD8E3FC
	}
	
	; MsgBox,,, %host% %activeMonitor% %color% %tabColor%
	; return

	if (activeSheet = "Kanban") {
		MouseGetPos, mx, my
		PixelGetColor, color, mx, my, RGB
		PixelGetColor, color3, mx, headerY, RGB ; Detect if a cell in the Done column is selected.	
		; MsgBox,,, %host% %mx% %my% %headerY% %color% %color3%
		; return
	
		if ((color = 0xDAEAD5) or (color = 0xD9EAD3) or (color = 0xDAEAD2)) {
			hoveringOverDoneColumn := true
		}
		if (color = 0xDDE9D6) { ; Zenbook
			hoveringOverDoneColumn := true
		}
		if ((color3 = doneSelected) or (color2 = doneSelected2)) {
			doneColumnSelected := true
		}
		if (hoveringOverDoneColumn and doneColumnSelected) {
			; We're hovering in the (green) Done column.
			; Assume over the top non-header cell.
			SetKeyDelay, 41, 20
			; Strangely, if you use left shift down/up, it toggles the keyboard language in Windows.
			; Even though the Windows shortcut for that is <W space> and has been disabled.
			; Send, {LShift Down}
			; Send, {Down 7}
			Send, +{Down}
			Send, +{Down}
			Send, +{Down}
			Send, +{Down}
			Send, +{Down}
			Send, +{Down}
			; Send, {LShift Up}
			Send ^c
			ClipWait	
			Send {Backspace}
			; Send {Delete} ; First one doesn't always do it.
			Sleep 201
			SetKeyDelay, 11, -1 ; default
			

			; Copy completed tasks to progress text file using Vim.
			; file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
			file = G:\My Drive\Organization\Progress\Home\Progress (Home).txt
			Run %file%
			Sleep 201
			SetTitleMatchMode, 3
			WinActivate, GVIM
			WinWaitActive, GVIM
			Send gg
			; This is a bit weird because when you hit /, Vim advances a character, so it does not
			; find the first date line in the file.
			year := A_Year - 2001
			Send /1%year%-{Enter}
			Send o
			Send ^v
			Send {Enter}
			Send {Esc}
			Sleep 101
			Send ^s ; My Vim saves the file when this is pressed.
		}
		else { ; Marking a single task done.
			; Mark as done in Kanban sheet using Move to Done macro.
			Send ^+!3
		}
	}
	else if (activeSheet = "Recurring") {
		; Mark as done in Recurring sheet.
		SetKeyDelay, 26, 25
		Send ^b
		Send {right 6}
		Send ^;
		Send {left 6}
		SetKeyDelay, 0, -1
	}
	else {
		Send ^d
	}
return

; Sort by Score descending.
; I end up doing this a lot after marking items as done or at the start of each new day.
; I recorded a macro in Google Sheets that does this when you press <C-A-S 2>.
; This just makes <C s> trigger it instead.
$^s::
	EnvGet, host, COMPUTERNAME
	activeMonitor := activeMonitorName()
	activeSheet := activeSheet()	
	
	; MsgBox,,, %host% %activeSheet%
	; return

	if (activeSheet = "Recurring") {
		; Run the Google app script to sort sheet by Score column.
		Send ^+!2
	}
	else {
		Send ^s
	}
return

; Show info about all monitors.
$^m::
	activeMonitor := activeMonitorName()
	MsgBox,,, %activeMonitor%
return

; Make it so Esc dismisses the search dialog if it is present.
$^f::
	searchDialog := 2
	Send ^f
return

Esc::
	if (searchDialog) {
		Send ^f
		Send {tab}{tab}
		Send {enter}
		searchDialog := 1
	}
return

; <A click> toggles between cut and paste.
; All the normal modifier keys cause unwanted side behavior.
/*
Esc & LButton::
	Click
	Sleep 21
	if (!kanbanCut) {
		SendInput ^c
		Sleep 51
		SendInput {delete}
		Sleep 51
		SendInput {backspace}
	}
	else {
		Send ^+v
	}
	kanbanCut := !kanbanCut
return
*/

; <A p> => Transition to progress file from kanban.
$!p::
	; file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
	file = G:\My Drive\Organization\Progress\Home\Progress (Home).txt
	Run %file%
return
#IfWinActive


; Make cut and paste work right in work kanban.
#IfWinActive ahk_group WorkKanban
$^v::
	; The problem with this is now if you paste any multiline cell, it pastes it as multiple cells.
	; clipboard := trim(clipboard, """") ; Remove outer double quotes.
	; Paste values only since my columns are color coded.
	Send ^+v
return

; For some reason, normal cut doesn't work.  This fixes it.
$^x::
	SendInput ^c
	Sleep 51
	SendInput {delete}
	Sleep 51
	SendInput {backspace}
return


; <A click> toggles between cut and paste.
; All the normal modifier keys cause unwanted side behavior.
/*
Esc & LButton::
	Click
	Sleep 21
	if (!kanbanCut) {
		SendInput ^c
		Sleep 51
		SendInput {delete}
		Sleep 51
		SendInput {backspace}
	}
	else {
		Send ^+v
	}
	kanbanCut := !kanbanCut
return
*/

; Make it so Esc dismisses the search dialog if it is present.
$^f::
	searchDialog := 2
	Send ^f
return

Esc::
	if (searchDialog) {
		Send ^f
		Send {tab}{tab}
		Send {enter}
		searchDialog := 1
	}
return

; <A p> => Transition to progress file from kanban.
$!p::
	; file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\UVU\%A_YYYY%\Progress (UVU).txt
	file = G:\My Drive\Organization\Progress\UVU\%A_YYYY%\Progress (UVU).txt
	Run %file%
return

#IfWinActive


#IfWinActive Inoreader ahk_class MozillaWindowClass
$+Down::
	; <S down> => mark as read.
	Send m
return

$+Up::
	; <S up> => star.
	Send f
return
#IfWinActive


;-------------------------------------------------------------------------------
; <C-w> in Sumatra PDF Reader closes the app.
#IfWinActive ahk_class SUMATRA_PDF_FRAME
$^w::
    WinClose, A
return
#IfWinActive


; Trying to remap <C k> to <C v> for Programmer Dvorak causes problems
; with PyCharm/WebStorm commit and pull shortcuts.
; Vaio Laptop and Dell XPS 411.
; A1  02A	 	d	0.03	Left Shift
; 3D  152	 	d	0.02	Insert
; 3D  152	 	u	0.09	Insert
; A1  02A	 	u	0.14	Left Shift
; $^k::
    ; ; TO DO: This does not work on my Windows 8 64-bit workstation.
    ; WinGetClass, class, A
    ; if (class = "mintty") {
        ; ; Apparently, {Insert} does not map to the insert key on my Vaio laptop.
        ; ; Send {vkA1sc02A Down}{vk2Dsc152}{vkA0sc02A Up}
        ; Send +{vk3Dsc152}
    ; }
    ; else { ; Not mintty.
        ; Send ^v
    ; }
; 
; 
; return


;-------------------------------------------------------------------------------
; PyCharm
#IfWinActive ahk_exe pycharm65.exe

; Compensate for Programmer Dvorak weirdness.
; What AHK sees as <A [>, PyCharm sees as <A 8>.  What I'm trying to press is <A 2>.
; You'd need to press shift to get 3 in Programmer Dvorak, but that messes it up somehow.
; ![:: -- Nope, AHK can't see this.
$!sc004::
	; The problem is, AHK has to use an alternate method of sending <A 3> since that combination
	; actually is not possible in Programmer Dvorak.
	; Since what it sends is not a key event, it can't trigger shortcut behavior.
	; Send !3

	; Watching its Keymap, PyCharm thinks you've hit <A 3> when you hit <A )> and emit that virtual key.
	; WORKS!
	Send !{vk33sc009}

return

#IfWinActive

;-------------------------------------------------------------------------------
; Make <Ctrl + V> paste into PuTTY windows.
; Usually, <Ctrl + V> lets you insert the next character literally.  This is rarely used.
; I've used it to define keymappings for bash via bind mainly.
;
; Strangely, a physical right click in the window automatically pastes, whereas AHK sending a right click
; brings up a context menu.  Curious.
;
; TO DO: <Shift + Insert> also pastes, so probably more responsive to map to that.
#IfWinActive ahk_class PuTTY
$^v::
    ; Send +{Insert}
    ; On my laptop, {Insert} is not defined correctly in AHK.
    ; On Windows 8 machine, it is the same.
    Send +{vk3Dsc152}

    ; Click Right
    ; Sleep 11
    ; Send {Down}
    ; Sleep 11
    ; Send {Enter}

return

#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + W> close PuTTY windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class PuTTY
$^w::
    WinClose A
    Sleep 21
    Send {Enter} ; Dismiss confirm dialog.

return


#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + W> close Cygwin/mintty windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class mintty
$^w::
    WinClose A

return
#IfWinActive


;-------------------------------------------------------------------------------
; <Alt + F2> => look up AutoHotkey docs (when we're editing .ahk files in Cygwin)
; <A-W h> => ditto
/*
!#h::
!F2::
	; MsgBox,,, Triggered
	GoSub, GetAutoHotkeyHelp
return

GetAutoHotkeyHelp:
	topic := Clipboard
	Run, https://www.autohotkey.com/docs/%topic%
	speak("Autohotkey help")
	Sleep 501
	WinActivate, ahk_exe firefox.exe
return
*/

;-------------------------------------------------------------------------------
; Make <Ctrl + W> close AHK help windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class HH Parent
$^w::
    WinClose A

return
#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + W> close Pidgin windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class gdkWindowToplevel
$^w::
    WinClose A

return
#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + W> close Preview windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class Photo_Lightweight_Viewer
$^w::
    WinClose A

return
#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + V> paste into Cygwin/mintty windows.
; Usually <Ctrl + V> lets you insert literal characters (like control characters).
; You'll have to disable Master.ahk to get that back in the rare cases that you need it.
; #IfWinActive ahk_class mintty
; $^v::
    ; Send +{Insert}
;    Send +{vk3Dsc152}

;return
;#IfWinActive

;==============================================================================
; Firefox
;==============================================================================

;-------------------------------------------------------------------------------
; Make <Ctrl + T> open a new Google tab in Firefox (instead of a blank).
; Firefox is brain dead in this regard.  Why would you want to open a blank tab???
; Bloody brilliant.  This works like a charm.
;
; TIP: <Ctrl + Shift + T> resurrects the last tab you (accidentally) closed.
#IfWinActive ahk_exe firefox.exe
$^t::
    ; Create the new tab.
    Send ^t
    ; Go to the address bar.
    Send ^l
    ; Type in Google address.
    Send www.google.com{Enter}

return


; Adds current URL to Bookmarks Toolbar|Now bookmarks.
$^d::
	Send ^d ; Open save new bookmark dialog.
	Sleep 501
	Send {Tab}{Tab}{Enter} ; Open dialog to choose folder.
	Sleep 201
	Send n ; Choose bookmarks toolbar N folder.
	Sleep 201
	Send !{Enter} ; Submit dialog.
return


; <S-W click> => Delete the bookmark you are hovering over.
; Using just <W click> causes the Windows menu to accidentally pop up too much.
$+#LButton::
	Send, {AppsKey}d
return

; Let's try having ;; delete the bookmark.
:*:;;::
	; Latest Firefox changed the menu item to "remove" with e as accelerator key.
	; Send, {AppsKey}e
	; And now they changed it back.
	Send, {AppsKey}d
return


;------------------------------------------------------------------------------
; Make <click + w> close tabs in Firefox.

/*
; Make w a hotkey that sends itself so we can use A_PriorHotkey.
$w::
	W_HOTKEY := A_ThisHotKey
	Send w
return
*/

/*
This causes touchscreen scrolling to not work.

; With w defined as a hotkey, we can now use this to trigger a specific action if
; we click the mouse shortly after pressing w.
; It's like having a LButton & w hotkey (which I couldn't get to work directly).
; PRE: This might not work tapping the laptop mousepad (vs. clicking the actual left button)
; unless using #InstallMouseHook.
; But, this seems to stop working after a few times if I use those directives.
$LButton::
	; Set this time too long, and triggering in inconsistent.
	; Set it too high, and you risk accidentally closing the window when not intended.
	if (A_PriorHotkey = W_HOTKEY) && (A_TimeSincePriorHotkey <= 501) {
		Send ^w
	}
	else { ; Do a normal left click.
		; Without this left button drags fails.
		Send {LButton down}
		KeyWait, LButton
		Send {LButton up}
		; MsgBox,,, clicked
	}
return
*/

#IfWinActive


;==============================================================================
; Chrome
;==============================================================================

; This ensures the hotkey only works when Google Chrome is the active window
#IfWinActive ahk_exe chrome.exe

toggle_autoscroll:
    ; Toggle the variable between true and false
    toggled := !toggled
    
    if (toggled) {
		MouseGetPos, mouse_x_start, mouse_y_start

        ; Start sending the Down arrow every 1001ms (1 second)
        SetTimer, SendDownKey, 751
        ToolTip, Autoscroll ON
        SetTimer, RemoveToolTip, -1999 ; Hide tooltip after 2 seconds
    } 
	else {
        ; Stop the timer
        SetTimer, SendDownKey, Off
        ToolTip, % "Autoscroll OFF: toggled by hotkey"
        SetTimer, RemoveToolTip, -1999
    }
return

; I keep accidentally hitting <C s> to activate this.
^s::
    IfWinActive, YouTube ahk_exe chrome.exe
    {
		Gosub, toggle_autoscroll
		return
	}
	Send, ^s

return

; Autoscroller mainly for YouTube.
^+s::
	; For some reason, putting the code in a function does not work.
	Gosub, toggle_autoscroll
return

SendDownKey:
	; Check current position
    MouseGetPos, mouse_x, mouse_y
    
    ; Calculate distance moved
    if (Abs(mouse_x - mouse_x_start) > 11 or Abs(mouse_y - mouse_y_start) > 10)
    {
        toggled := false
        SetTimer, SendDownKey, Off
        ToolTip, Autoscroll OFF: mouse moved
        SetTimer, RemoveToolTip, -1999
    }


    ; Safety check: Only send the key if Chrome is still the active window
    IfWinActive, ahk_exe chrome.exe
    {
        Send, {Down}
    }
    else
    {
        ; Stop if you switch away from Chrome to prevent mess-ups elsewhere
        toggled := false
        SetTimer, SendDownKey, Off
        ToolTip, Autoscroll OFF: changed windows
        SetTimer, RemoveToolTip, -1999
    }
return

RemoveToolTip:
    ToolTip
return

#IfWinActive


;-------------------------------------------------------------------------------
; Ableton Live

/*
Ableton Live
*/

#IfWinActive ahk_exe Ableton Live 13 Lite.exe

;$^t::
	;MsgBox,,, active
;return

; Remap shortcut to toggle browser for Programmer Dvorak.
$^!(::
	;FAIL: It's not working!
	;MsgBox,,, active
	;SendInput {Ctrl Down}{Alt Down}6{Ctrl Up}{Alt Up}
	/*	
	SendPlay {LCtrl down}
	Sleep 51
	SendPlay {LAlt down}
	Sleep 51
	SendPlay 6
	Sleep 51
	SendPlay {LAlt up}
	SendPlay {LCtrl up}
	Send {tab}
	*/

	/* This should work but doesn't!
	Send {vkA3scO1D down}
	Sleep 11
	Send {vkA5sc038 down}
	Sleep 11
	Send {vk36sc006 down}
	Sleep 11
	Send {vk36sc006 up}
	Sleep 11
	Send {vkA5sc038 up}
	Sleep 11
	Send {vkA3scO1D up}
	*/
	; This is Live's other keyboard shortcut to toggle browser.
	Send ^!{b}

/*
A3  01D	 	d	10.84	LControl       	
A5  038	 	d	0.05	LAlt           	
36  006	 	d	0.20	5              	
36  006	 	u	0.08	5              	
A5  038	 	u	0.34	LAlt           	
A3  01D	 	u	0.01	LControl  
*/
return

#IfWinActive

;==============================================================================
; Keyboard
;==============================================================================


;-------------------------------------------------------------------------------
; Remap {Left} to my keyboard's left arrow.
; {Left} => Numpad5 on this laptop for some reason.
;
; Without doing this, automating context menus doesn't work.
/*
VK65::
    Send, {vk26sc14B}
return

; Remap {Down} to my keyboard's down arrow
VK69::
    Send, {vk29sc150}
return
*/

; {vk28sc14D} => right arrow


;-------------------------------------------------------------------------------
; Make h => {Down} and l => {Up} in Sumatra PDF Reader
; This could be a problem if I type something in a search field or whatnot.
#IfWinActive ahk_class SUMATRA_PDF_FRAME
$l::
    Send {vk27sc148}
return

$h::
    Send {vk29sc150}
return

#IfWinActive


;==============================================================================
; Windows Explorer
;==============================================================================

;-------------------------------------------------------------------------------
; Open command prompt at current folder in Explorer.
; <Ctrl + Alt + c> in Windows Explorer.
; http://lifehacker.com/5306402/open-a-new-command-prompt-from-explorer-with-a-hotkey
#IfWinActive ahk_class CabinetWClass ; Only applies to Explorer.
$^!c::
    ClipSaved := ClipboardAll
    Send !d
    Sleep 11
    Send ^c
    ClipWait, 3
    if ErrorLevel {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    } ; if

    Run, cmd /K "cd `"%clipboard%`""
    Clipboard := ClipSaved
    ClipSaved =
return

; Closes all Explorer windows when <A-S F5> pressed.
!+F5::
	if ( WinExist("ahk_group ExplorerGroup") )
	WinClose,ahk_group ExplorerGroup
return

; <A d> => new directory in Windows Explorer.
$!d::
	Send ^+n
	; Send +{F11}wf
return

; <A t> => new text file in Windows Explorer.
$!t::
	Send +{F11}wt
return
#IfWinActive


; <C w> => minimize window in KeePaas.
; By default, it closes the open file which is never what I want to do.
#IfWinActive ahk_exe KeePass.exe
$^w::
	WinMinimize
return


;-------------------------------------------------------------------------------
; Gets rid of citation crap when copying from Kindle.
; BUG: Only works if copying a single line.
; TO DO: Have it just chuck the last two lines instead of only keeping the first.
; <C-c> in Kindle.
#IfWinActive ahk_class QWidget
$^c::
    Send ^c
    ClipWait, 3
    contents := Clipboard

    fixed =
    count = 1
    Loop, parse, contents, `n
    {
        ; MsgBox,,,%A_LoopField% %count% %contents%
        ; MsgBox,,,%A_LoopField%
        count += 2
        if (count == 2) {
            fixed = %A_LoopField%
        }

    }

    StringReplace, fixed, fixed, `n, , All
    StringReplace, fixed, fixed, `r, , All
    Clipboard := fixed

return
#IfWinActive


; Speak (pronounce) what's on the clipboard.
$!^p::
	global OPT_SPEAK
	saved := OPT_SPEAK
	OPT_SPEAK := 2
	speak(clipboard)
	OPT_SPEAK := saved
return


;-------------------------------------------------------------------------------
; Pronounces highlighted word in Kindle (using a Google search).
; <A-p> in Kindle.
#IfWinActive ahk_class QWidget
$!p::
    x =
    y =
    ; FAIL
    ; s := dpiScaleFactor("REG")
    s =
    ; These are Windows env vars.
    EnvGet, host, COMPUTERNAME
    if (host = "XPS16") {
        x := 381
        y := 281
    }
    else if (host = "INSPIRON") {
        ; Something is wrong.  Coordinates displayed by Window Spy do not match.
        ; Is it a Windows DPI thing?
        ; Yes, I have Control Panel | Display | Change size of all items | 151%.
        ; AHK reports the now translated coordinates, but Windows expects the translated coordinates.
        s := 2.5
        x := 401 * s
        y := 291 * s
    }
    else {
        MsgBox,,Error, Unrecognized host.
        return
    }

    Send ^c
    ClipWait, 3
    contents := Clipboard

    fixed =
    count = 1
    Loop, parse, contents, `n
    {
        ; MsgBox,,,%A_LoopField% %count% %contents%
        ; MsgBox,,,%A_LoopField%
        count += 2
        if (count == 2) {
            fixed = %A_LoopField%
        }

    }

    StringReplace, fixed, fixed, `n, , All
    StringReplace, fixed, fixed, `r, , All
    StringReplace, fixed, fixed, "·", , All
    ; Get rid of accent marks.
    fixed3 := RegExReplace(fixed, "[^abcdefghijklmnopqrstuvwxyz]", "")
    fixed := fixed3
    Clipboard := fixed

    Run http://www.google.com
    WinWait, Google - Mozilla Firefox
    WinWaitActive, Google - Mozilla Firefox
    Send define %fixed%
    Send {Enter}
    Sleep 2001
    MouseMove, x, y
    Click 3
    Send {Tab}
    Sleep 201
    Click 3
    Send {Tab}
    Send {Enter}


return
#IfWinActive

; TO DO: Can we factor all these <C w> things down?
#IfWinActive Jeff's Kindle
; Makes <C w> close Kindle app.
^w::
	Send !{F5}
return
#IfWinActive

#IfWinActive ahk_exe Discord.exe
; Makes <C w> close Discord.
^w::
	Send !{F5}
return
#IfWinActive

#IfWinActive Weather
; Make <C w> close the Windows Weather app.
^w::
	Send !{F5}
return
#IfWinActive



;-------------------------------------------------------------------------------
; Opens Cygwin command prompt at current folder in Windows Explorer.
; PRE: You have not hidden the address bar.
; <A-C> in Windows Explorer.
#IfWinActive ahk_class CabinetWClass ; Only applies to Explorer windows.
$!c::
    saved := ClipboardAll
    ; Go to address bar and select path there.
    Send ^l
    Sleep 11
    ; Copy the path.
    Send ^c
    Sleep 11
    ClipWait, 3
    if ErrorLevel {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    } ; if

    ; Run Cygwin.
    Run, C:\cygwin65\bin\mintty.exe -i /Cygwin-Terminal.ico -
    WinWait, ~
    WinActivate, ~
    WinMaximize, ~
    ; Go to the path from Windows Explorer.
    ; Have to use cygpath to translate Windows path into a Cygwin path.
    Send cd "$(cygpath '%clipboard%')"{Enter}

    ; Restore clipboard.
    Clipboard := saved
    saved =
return
#IfWinActive


; <Ctrl + Alt + C> when not in Windows Explorer.  Default behavior.
$^!c::
    ; Run C:\Windows\System33\cmd.exe /K "cd %HOMEDRIVE%%HOMEPATH%"
    Run C:\Users\Jade Axon\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\Command Prompt.lnk
return


;-------------------------------------------------------------------------------
; Allow normal pasting in Command Prompt.
; Checks for Command Prompt.  <Ctrl + v> => Send the raw clipboard data.
#IfWinActive ahk_class ConsoleWindowClass
$^v::
    SendInput {Raw}%clipboard%
return

; Dvorak. The automapping fails here.
$^k::
    SendInput {Raw}%clipboard%
return


#IfWinActive


;-------------------------------------------------------------------------------
; <Window + p> => Copy a relative MouseMove(x, y) at current mouse location.
$#p::
    MouseGetPos, x, y
    Clipboard = MouseMove %x%, %y%

return


;===============================================================================
; gVim

; Do not Dvork 1 => Qwerty S in gVim.
; <Ctrl + O> in gVim undoes last movement command, restoring cursor position.
; Well, that's not exactly what the command does.  But it is like a back button
; of some sort.
#IfWinActive ahk_class Vim
$^o::
    Send ^o
return
#IfWinActive


;===============================================================================
; Submode Launching


/*
Disable since Windows 12 uses <W n> for notifications.
Also, I basically never use my navigation mode.
;-------------------------------------------------------------------------------
; <Window + n> => Navigation mode.
$#n::
    SoundPlay %A_ScriptDir%\Sounds\Navigation_Start.wav

    ; NOTE: The Windows file assosciation for Open on .ahk files must be set to AutoHotKey.exe.
    Run %A_ScriptDir%\Navigation.ahk
return
*/

;-------------------------------------------------------------------------------
; <Window + d> => Debug mode.
$#d::
    ; SoundPlay %A_ScriptDir%\Sounds\Debug_Start.wav
    ; Run C:\Users\Jade Axon\Desktop\AHK\Debug.ahk
    Run %A_ScriptDir%\Debug.ahk
return


;-------------------------------------------------------------------------------
; <Window + v> => Paste mode.
$#v::
    ; SoundPlay %A_ScriptDir%\Sounds\Paste_Start.wav
    ; Run C:\Users\Jade Axon\Desktop\AHK\Paste.ahk
    Run %A_ScriptDir%\Paste.ahk
return


;-------------------------------------------------------------------------------
; <Window + k> => Mouse keys mode.
;
; The arrow keys move the mouse.
; <Ctrl + Up> => finer vertical rez
; <Ctrl + Right> => finer horizontal rez
; <Spacebar> => left click
; etc.
$#k::
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Sounds\MouseKeys_Start.wav
    SoundPlay %A_ScriptDir%\Sounds\MouseKeys_Start.wav
    ; Run C:\Users\Jade Axon\Desktop\AHK\MouseKeys.ahk
    Run %A_ScriptDir%\MouseKeys.ahk
return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + w>
; Show info for all windows.

$^!w::
    ; Example #3: This will visit all windows on the entire system and display info about each of them:
    WinGet, id, list,,, Program Manager
    Loop, %id% {
        this_id := id%A_Index%
        WinActivate, ahk_id %this_id%
        WinGetClass, this_class, ahk_id %this_id%
        WinGetTitle, this_title, ahk_id %this_id%
        MsgBox, 5, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
        IfMsgBox, NO, break
    }
return




;===============================================================================
; SHORTCUTS


;-------------------------------------------------------------------------------
; <Window + M> => Do normal Window + M, but maximize Pidgin development chat if it exists.
$#m::
    EnvGet, host, COMPUTERNAME


    Send #m

    Sleep 151
    ; WinMaximize, swdev, Pidgin
    ; WinMaximize, (swdev), Pidgin

    ; Mainly on my desktop at digEcor should this happen.
    if (host != "XPS16") {
        x := 381
        y := 281

        ; This is a hack until I put in code which detects which monitor each window is in.
        ; WinMaximize, Ubuntu 14 64-bit - VMware Player
        ; WinMaximize, XChat

        ; For Outlook 2014.
        ; WinMaximize, Inbox
        ; WinMaximize, Calendar - Jeffrey.Anderson@uvu.edu - Outlook

    }
return


;-------------------------------------------------------------------------------
; Remapping for the Logitech LX9 Cordless Laser mouse on my Windows 7 workstation at digEcor.
; Also remapped on my Razer Naga Hex on Windows 9 using the Razer Synapse software.

; The back button on the mouse is mapped to <Ctrl + Shift + M>.
; You can't assign <Window + M> directly, so I will remap.

; In this case, we *do* want hotkey retriggering by Send because I have <Window + M> remapped
; not to minimize development chat in P!
; Unfortunately, it isn't retriggering for some other reason.  So, must factor out into a function.
; Or just copy and paste.

; <mouse back button> => <Ctrl + Shift + M> => <Window + M>
$^+m::
    Send #m
    Sleep 151
    ; WinMaximize, swdev, Pidgin
    ; WinMaximize, (swdev), Pidgin

    ; This is a hack until I put in code which detects which monitor each window is in.
    ; Need to disable these in Brisbane since only have 2 monitor here.
    WinMaximize, Ubuntu 14 64-bit - VMware Player
    WinMaximize, XChat
    ; For Outlook 2014.
    WinMaximize, Inbox
    WinMaximize, Calendar - Jeffrey.Anderson@uvu.edu - Outlook

return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + M> => <Window + M>
; Doing this for Razer Synapse since I can't enter <Window + M> into their edit screen.
$^!m::
    Send #m
return


;-------------------------------------------------------------------------------
; <C-A j> => Jeff's GUI.
; <A-W m> => Modes GUI.

$!#m::
$^!j::
	; Check if GUI already exists.
	Gui, +LastFoundExist
	if WinExist() {
		WinActivate ; Activate last found given no args.		
		speak("Modes window")
		return
	}

    ; Gui, Add, Button, gButton_HomeContexts w251 default, &Home Contexts
    ; Gui, Add, Button, gButton_WorkContexts w251, &Work Contexts
	; Gui, Add, Button, gButton_Agendas w251, &Agendas
	; Gui, Add, Button, gButton_Recurring w251, &Recurring

	; WARNING; The checkbox does not sync with the value of its out var on creation!
	; Also, it seems like you need to put "checked" first in the options arg.
	isChecked := (OPT_LEFT_SCROLL) ? "checked" : ""
	
	; Mark this GUI as being the "last found" window.
	Gui, +LastFound	
	Gui, Add, Checkbox, %isChecked% vOPT_LEFT_SCROLL gOPT_LEFT_SCROLL, Enable &scrolling with left control and shift?
	isChecked := (OPT_SPEAK) ? "checked" : ""
	Gui, Add, Checkbox, %isChecked% vOPT_SPEAK gOPT_SPEAK, Spea&k when hotkeys and hotstrings are triggered?
	Gui, Add, Button, gButton_Budget w251, &Budget
	Gui, Add, Button, gButton_MouseJiggler w251, &Mouse Jiggler	
	Gui, Show,, Modes
	
	speak("Modes window")

return

OPT_LEFT_SCROLL:
	; The value of the checkbox doesn't save to the linked variable until the GUI is submitted.
	Gui, Submit, NoHide
	; MsgBox,,, %OPT_LEFT_SCROLL%
return

OPT_SPEAK:
	Gui, Submit, NoHide
	; MsgBox,,, %OPT_SPEAK%
return


; TO DO: Factor button handlers into single "open all in given folder in single gVim" function.
; TO DO: Verify works on XPS16.

; Open all @ files in home contexts in a single gVim.
Button_HomeContexts:
	Gui, Destroy
	; Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Home
	Run G:\My Drive\Organization\To Do\Contexts\Home
	Sleep 1001
	Send #{Up}
	Sleep 101
	MouseMove 1451, 430
	Click
	Sleep 101
	Send {PgUp}
	Sleep 51
	Send {PgUp}
	Sleep 51
	Send ^a
	Sleep 501
	Send +{F11}
	Sleep 201

	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51

	Send {Enter}
	WinWait 501
	WinActivate GVIM

return


; Open all @ files in work contexts in a single gVim.
Button_WorkContexts:
	Gui, Destroy
	; Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Work
	Run G:\My Drive\Organization\To Do\Contexts\Work
	Sleep 1001
	Send #{Up}
	Sleep 101
	MouseMove 1451, 430
	Click
	Sleep 101
	Send {PgUp}
	Sleep 51
	Send {PgUp}
	Sleep 51
	Send ^a
	Sleep 501
	Send +{F11}
	Sleep 201

	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51

	Send {Enter}
	WinWait 501
	WinActivate GVIM

return


; Open all @ files in agendas in a single gVim.
Button_Agendas:
	Gui, Destroy
	; Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Agendas
	Run G:\My Drive\Organization\To Do\Agendas
	Sleep 1001
	Send #{Up}
	Sleep 101
	MouseMove 1451, 430
	Click
	Sleep 101
	Send {PgUp}
	Sleep 51
	Send {PgUp}
	Sleep 51
	Send ^a
	Sleep 501
	Send +{F11}
	Sleep 201

	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51

	Send {Enter}
	WinWait 501
	WinActivate GVIM

return


; Open all recurring tasks files in a single gVim.
Button_Recurring:
	Gui, Destroy
	; Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Recurring
	Run G:\My Drive\Organization\To Do\Contexts\Recurring
	Sleep 1001
	Send #{Up}
	Sleep 101
	MouseMove 1451, 430
	Click
	Sleep 101
	Send {PgUp}
	Sleep 51
	Send {PgUp}
	Sleep 51
	Send ^a
	Sleep 501
	Send +{F11}
	Sleep 201

	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51
	; The context menu pops up different in this folder, so need to go down 3 more.
	Send {Down}
	Sleep 51
	Send {Down}
	Sleep 51

	Send {Enter}
	WinWait 501
	WinActivate GVIM

return


; Updates current budget file.
; PRE: You've copied the expense amount to the clipboard.
; PRE: gVim is the default app for .txt files.
; PRE: NEXT is on a line by itself in the budget file where the next entry should go.
Button_Budget:
	Gui, Destroy
	
	remainingBudget := ""
	amount := 1

	amount := Clipboard
	StringReplace amount, amount, $,
	StringReplace amount, amount, `,, ; In case we're over $2,000.	
	amount := abs(amount)

	if (amount <= 1) {
		MsgBox,, Error, You did not copy an amount to the clipboard.
		return
	}

	Clipboard := ""

	; Open budget file in gVim.
    EnvGet, home, USERPROFILE
	; Run, %home%\Dropbox\Organization\Financial\Budget\%A_YYYY%\%A_YYYY% Budget.txt
	Run, G:\My Drive\Organization\Financial\Budget\%A_YYYY%\%A_YYYY% Budget.txt
	Sleep 501
	WinActivate ahk_exe gvim.exe
	WinWaitActive ahk_exe gvim.exe

	; Vim commands.
	SendInput, {esc}{esc}
	SendInput, gg
	SendInput, /NEXT{enter}
	SendInput, {up}
	SendInput, "{+}yW

	; Get remaining budget amount from the clipboard.
	ClipWait 1
	remainingBudget := Clipboard

	; Remove leading $.
	StringReplace remainingBudget, remainingBudget, $,
	StringReplace remainingBudget, remainingBudget,  `,, ; In case we're over $2,000.	
	; MsgBox % remainingBudget

	remainingBudget := abs(remainingBudget)

	; Get the new remaining budget rounded to two decimal points.
	newRemainingBudget := remainingBudget - amount
	newRemainingBudget := round(newRemainingBudget, 3)

	; MsgBox,,, orb: %remainingBudget%`namt: %amount%`nnrb: %newRemainingBudget%
	
	out := "$" . newRemainingBudget
	out := RegExReplace(out, "(\d)(?=(?:\d{4})+(?:\.|$))", "$1,") ; Commify number.

	amount := Format("{:.3f}", amount) ; Round to 2 decimal places.
	SendInput, o
	SendInput, %out%{space}-$%amount%{space}
	; You should now type in the purchase description.

return

Button_MouseJiggler:
	Gui, Destroy
	Run %A_ScriptDir%\MouseJiggler.ahk
return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + d> => Popup common tasks at digEcor.
; I've disabled this so <C-A d> can be used for day mode (since no longer work at digEcor).

; $^!d::
Disabled:
    Gui, Add, Button, gButton_ClockIn w151 default, Clock &In

Gui, Add, Button, gButton_ClockOut w151, Clock &Out
    Gui, Add, Button, gButton_TimeCard w151, &Time Card
    Gui, Show,, digEcor

return

; TO DO: Modify these to wait for symbols.

; TO DO: When A Plus' site is down, you can still access the timeclock here: https://www.swipeclock.com/sc/clock/webclock.asp

; Clocks into digEcor (APlus) time clock.
Button_ClockIn:
    Gui, Destroy
	Run https://clock.payrollservers.us/?wl=aplusbenefits.payrollservers.us#/clock/web/login
	WinWait, WM Clock
    WinActivate, WM Clock

    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F5}
    Sleep 251
    ; Reactivate because RoboForm steals focus.
    WinActivate, WM Clock
    WinWaitActive, WM Clock

	password := property("aplus.timeclock.password")
    Send {Tab}
	Send janderson{Tab}
    Send %password%{Tab}
	Send {Enter}

    ; In case another one pops back up.
	Sleep 7001
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F5}
    }

	x := 601
	y := 553
	EnvGet, host, COMPUTERNAME
	if (host = "JANDERSON-DT") {
		x := 887
		y := 617
	}

	MouseMove x, y
	Sleep 1001
	Click

return


; Clock out of digEcor (APlus) time clock.
Button_ClockOut:
    Gui, Destroy
	Run https://clock.payrollservers.us/?wl=aplusbenefits.payrollservers.us#/clock/web/login
	WinWait, WM Clock
    WinActivate, WM Clock

    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F5}
    Sleep 251
    ; Reactivate because RoboForm steals focus.
    WinActivate, WM Clock
    WinWaitActive, WM Clock

	password := property("aplus.timeclock.password")
    Send {Tab}
	Send janderson{Tab}
    Send %password%{Tab}
	Send {Enter}

    ; In case another one pops back up.
	Sleep 7001
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F5}
    }

	x := 771
	y := 553
	EnvGet, host, COMPUTERNAME
	if (host = "JANDERSON-DT") {
		x := 1046
		y := 612
	}
	MouseMove x, y
	Sleep 1001
	Click

return


; Show the digEcor (APlus) time card for the current week.
; TO DO: Fix.  New system broke this.
; PRE: You are logged out of the "Employee Self Service Portal".
Button_TimeCard:
    Gui, Destroy
    Run https://www.payrollservers.us/pg/Ess/TimeCard.aspx
    ; TO DO: If already logged into portal, this alone will do the trick.

	WinWait, Online Time and Attendance
    WinActivate, Online Time and Attendance

    Sleep 1001
	password := property("aplus.timeclock.password")
    Send {Tab}janderson{Tab}
    Send %password%{Enter}

	Sleep 1001
	Send ^w
	Run https://www.payrollservers.us/pg/Ess/TimeCard.aspx

return


; Cause (all) GUIs to be cancellable with the Esc key.  Sweetness!
; This block Launchy from closing by <Esc>.
; Esc::Gui Cancel
; This does the trick without messing up Launchy.
GuiEscape:
    Gui, Destroy
return


; You can only define this label in one spot.
GuiClose:
    Gui, Destroy
return


;-------------------------------------------------------------------------------
; <Window + S> => Toggle ShortKeys.
; A great example of how to automate tray icons regardless of their position.
; Well, it still had issues.
; Now just remaps to a shortcut key set inside ShortKeys.

; <Window + S> => <Ctrl + Alt + S> => enable/disable ShortKeys
$#s::
    ; toggleShortKeys()
    ; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being active
    Send ^!s

return



;-------------------------------------------------------------------------------
; <Ctrl + Space> => an abbreviation expansion activation that emits no character.
;
; This will emit <Space> <Backspace> so that ShortKeys abbreviations will expand,
; but with no trailing space.  Useful at the end of sentences.

; Unfortunately, this doesn't work.  Simply hitting <Ctrl> causes ShortKeys not to expand.
; It's like it resets ShortKeys' memory.
;~ $^Space::
    ;~ Send {Space}
    ;~ Sleep 1001
    ;~ Send {Backspace}

;~ return

;~ ; This fails too.
;~ $#Space::
    ;~ Send {Space}
    ;~ Sleep 1001
    ;~ Send {Backspace}

;~ return

; This works but is somewhat timing sensitive to how long it takes you to release the shift key and how long it takes ShortKeys to expand abbreviation.
; Well, this was an interesting idea, but it turn out to be annoying in practical use.
; $+Space::
;     Sleep 301 ; Give time for me to release the <Shift + Space> so <Shift> isn't held down while ShortKeys expands abbreviation.
;     Send {Space}
;     Sleep 301 ; Give time for ShortKeys to expand abbreviation.
;     Send {Backspace}
;
; return




;===============================================================================
; SCREEN CAPTURE

;-------------------------------------------------------------------------------
; Use the Windovs snippnig tool.
$^PRINTSCREEN::
    Run snippingtool
return


;-------------------------------------------------------------------------------
; Grab a screenshot of the active window and open it in Paint.
; <Window + PrintScreen>
$#PRINTSCREEN::
    Send, !{PrintScreen}
    Run, mspaint.exe
    Sleep 1001
    WinActivate, Untitled - Paint
    WinWaitActive, Untitled - Paint
    Send ^v
return


;===============================================================================
; ABBREVIATION HOTSTRINGS


; This hotstring replaces "<date>" with the current date and time via the commands below.
::<date>::
    FormatTime, monthDay,, d
    FormatTime, month,, MMMM
    FormatTime, weekDay,, dddd
    FormatTime, year,, yyyy

    monthDay := ordinal(monthDay)

    output = %weekday%`, %month% %monthDay%`, %year%

    ; FormatTime, output,, dddd`, MMMM` d`, yyyy
    SendInput %output%
return


; <ymd> => 2013/07/27
::<ymd>::
    FormatTime, year,, yyyy
    FormatTime, month,, MM
    FormatTime, day,, dd

    output = %year%/%month%/%day%
    SendInput %output%
return


; <ymd-> => 2013-07-27
::<ymd->::
    FormatTime, year,, yyyy
    FormatTime, month,, MM
    FormatTime, day,, dd

    output = %year%-%month%-%day%
    SendInput %output%
return


::<date-->::
    FormatTime, monthDay,, d
    FormatTime, month,, MMMM
    FormatTime, weekDay,, dddd
    FormatTime, year,, yyyy

    monthDay := ordinal(monthDay)

    minus := "-"
    equals := "="
    longBar := "-------------------------------------------------------------------------------------------------------------------------"


    dateString = %weekday%`, %month% %monthDay%`, %year%

    ; FormatTime, output,, dddd`, MMMM` d`, yyyy
    SendInput %longBar%
    SendInput {Enter}
    SendInput %dateString%
    SendInput {Enter}
    SendInput %longBar%
    SendInput {Enter}
    SendInput {Enter}

return


::<date==>::
    FormatTime, monthDay,, d
    FormatTime, month,, MMMM
    FormatTime, weekDay,, dddd
    FormatTime, year,, yyyy

    monthDay := ordinal(monthDay)

    minus := "-"
    equals := "="
    longBar := "========================================================================================================================="

    dateString = %weekday%`, %month% %monthDay%`, %year%

    ; FormatTime, output,, dddd`, MMMM` d`, yyyy
    SendInput %longBar%
    SendInput {Enter}
    SendInput %dateString%
    SendInput {Enter}
    SendInput %longBar%
    SendInput {Enter}
    SendInput {Enter}

return


; Do a date header for ymd=.
::ymd=::
	bar81 := "==============================================================================="
	FormatTime, dateString,, yyyy-MM-dd

    SendInput %bar81%
    SendInput {Enter}
    SendInput %dateString%
    SendInput {Enter}
    SendInput %bar81%
    SendInput {Enter}
    SendInput {Enter}

return





;==============================================================================
; Toad
;==============================================================================

; Adds some extra password-enterting power to the Toad F6 shortcut key.
; This deals with the table setup scripts that need the password twice.
#IfWinActive fzjebt_setup.sql ahk_class TfrmMain ahk_exe Toad.exe
$F6::
    EnvGet, home, USERPROFILE
	
	; Goddamn DBAs can't set the paswords consistently.
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All
	
	FileRead, password, %home%\.ssh\toad_password.txt
	password := Trim(password)
	StringReplace, password, password, `n, , All
	
	Send {F6}
	; This will time out in 4 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,4
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}
	SendRaw %old_password%
	Send {enter}
	Sleep 1001	
	
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe
	; Goddamn password has a # in it!
	SendRaw %password%
	Send {enter}

return
#IfWinActive


#IfWinActive codesep_table_setup.sql ahk_class TfrmMain ahk_exe Toad.exe
$F6::
    EnvGet, home, USERPROFILE
	
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All
	
	Send {F6}
	; This will time out in 4 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,4
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}
	SendRaw %old_password%
	Send {enter}
	
return
#IfWinActive


#IfWinActive fzjebt_table_setup.sql ahk_class TfrmMain ahk_exe Toad.exe
$F6::
    EnvGet, home, USERPROFILE
	
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All

	FileRead, password, %home%\.ssh\toad_password.txt
	password := Trim(password)
	StringReplace, password, password, `n, , All

	Send {F6}
	; This will time out in 4 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,4
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}

	SendRaw %old_password%
	Send {enter}
	
	Sleep 4001
	
	; This will time out in 4 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,4
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}
	SendRaw %password%
	Send {enter}
	
return
#IfWinActive




; <W-A w> => AHK Window Spy
$#!w::
	if (FileExist("C:\Program Files\AutoHotkey\AU4_Spy.exe")) {
		Run, C:\Program Files\AutoHotkey\AU4_Spy.exe
	}
	else if(FileExist("C:\Program Files\AutoHotkey\WindowSpy.ahk")) {
		Run, C:\Program Files\AutoHotkey\WindowSpy.ahk
	}
return

; <C w> => close AHK Window Spy
#IfWinActive ahk_exe AU4_Spy.exe
$^w::
	Send !{F5}
return
#IfWinActive

#IfWinActive Window Spy
$^w::
	Send !{F5}
return
#IfWinActive

; Make the Windows 11 settings window close via <C w>.
#IfWinActive Settings ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe
$^w::
	Send !{F5}
return
#IfWinActive


;-------------------------------------------------------------------------------
; <Ctrl + ESC> => Reload this script.
;
; Reload this AutoHotKey script.
; This is like sending a restart signal to a veb server so it can reload its configuration file.
#UseHook off
LControl & Escape::
	EnvGet, vUserProfile, USERPROFILE

	; These should probably be reloaded after this reloads, but this may be good enough.
	; Note that these do not get started if they aren't already running.
	Run, %vUSERPROFILE%\projects\modes-private\Private.ahk /restart
	Run, %vUSERPROFILE%\projects\modes\RegExHotstrings.ahk /restart

    ; *65 is one of the system sounds.
    SoundPlay *65
	speak("Reloading Modes")
    Reload

    ; This code can only be reached if reloading fails.
    Sleep 1001
    MsgBox 5, , Script reloaded unsuccessful, open it for editing?
    IfMsgBox Yes, Edit
return


;==============================================================================
; Functions
;==============================================================================

; converted
; Speaks given message using computer-generated voice.
speak(message) {
	Global OPT_SPEAK	
	if (OPT_SPEAK) {
		ComObjCreate("SAPI.SpVoice").Speak(message)	
	}
}

