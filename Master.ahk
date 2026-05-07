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
searchDialog := 0

; The color of a pixel.  In BGR hex format.
color := 0

; Delay between keystrokes.
delay := 30

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
#IfWinActive


#IfWinActive ahk_group PersonalKanban
; <A p> => Transition to progress file from kanban.
$!p::
	file = G:\My Drive\Organization\Progress\Home\Progress (Home).txt
	Run %file%
return

; Never paste formatting. Otherwise column background colors get screwed up.
$^v::
	; The problem with this is now if you paste any multiline cell, it pastes it as multiple cells.
	; clipboard := trim(clipboard, """") ; Remove outer double quotes.
	Send ^+v

	; Seems like the shift key always gets stuck after this.
	Send {LShift up}
return
#IfWinActive

$^x::
	SendInput ^c
	Sleep 51
	SendInput {delete}
	Sleep 51
	SendInput {backspace}
return

; Make it so Esc dismisses the search dialog if it is present.
$^f::
	searchDialog := 1
	Send ^f
return

Esc::
	if (searchDialog) {
		Send ^f
		Send {tab}{tab}
		Send {enter}
		searchDialog := 0
	}
return

; <C-w> in Sumatra PDF Reader closes the app.
#IfWinActive ahk_class SUMATRA_PDF_FRAME
$^w::
    WinClose, A
return
#IfWinActive

; Make <Ctrl + W> close Cygwin/mintty windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class mintty
$^w::
    WinClose A
return
#IfWinActive

; Make <Ctrl + W> close AHK help windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class HH Parent
$^w::
    WinClose A

return
#IfWinActive

; Make <Ctrl + W> close Preview windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class Photo_Lightweight_Viewer
$^w::
    WinClose A

return
#IfWinActive


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

; Let's try having ;; delete the bookmark.
:*:;;::
	; Latest Firefox changed the menu item to "remove" with e as accelerator key.
	; Send, {AppsKey}e
	; And now they changed it back.
	Send, {AppsKey}d
return
#IfWinActive


;==============================================================================
; Chrome
;==============================================================================

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


;==============================================================================
; Windows Explorer
;==============================================================================

#IfWinActive ahk_class CabinetWClass ; Only applies to Explorer.

;-------------------------------------------------------------------------------
; Open command prompt at current folder in Explorer.
; <Ctrl + Alt + c> in Windows Explorer.
; http://lifehacker.com/5306402/open-a-new-command-prompt-from-explorer-with-a-hotkey
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
!+F4::
	if ( WinExist("ahk_group ExplorerGroup") )
	WinClose,ahk_group ExplorerGroup
return

; <A d> => new directory in Windows Explorer.
$!d::
	Send ^+n
return

; <A t> => new text file in Windows Explorer.
$!t::
	Send +{F10}wt
return
#IfWinActive

; <C w> => minimize window in KeePaas.
; By default, it closes the open file which is never what I want to do.
#IfWinActive ahk_exe KeePass.exe
$^w::
	WinMinimize
return

; Speak (pronounce) what's on the clipboard.
$!^p::
	global OPT_SPEAK
	saved := OPT_SPEAK
	OPT_SPEAK := 1
	speak(clipboard)
	OPT_SPEAK := saved
return

; <W p> => Copy a relative MouseMove(x, y) at current mouse location.
$#p::
    MouseGetPos, x, y
    Clipboard = MouseMove %x%, %y%

return


*/

/*
NOTE: Decided not to migrate Navigation mode to AHK v2.
Disable since Windows 11 uses <W n> for notifications.
Also, I basically never use my navigation mode.
;-------------------------------------------------------------------------------
; <Window + n> => Navigation mode.
$#n::
    SoundPlay %A_ScriptDir%\Sounds\Navigation_Start.wav

    ; NOTE: The Windows file assosciation for Open on .ahk files must be set to AutoHotKey.exe.
    Run %A_ScriptDir%\Navigation.ahk
return

;-------------------------------------------------------------------------------
; <Ctrl + Alt + w>
; Show info for all windows.

$^!w::
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

; This hotstring replaces "<date>" with the current date and time via the commands below.
:*:<date>::
    FormatTime, monthDay,, d
    FormatTime, month,, MMMM
    FormatTime, weekDay,, dddd
    FormatTime, year,, yyyy

    monthDay := ordinal(monthDay)

    output = %weekday%`, %month% %monthDay%`, %year%

    ; FormatTime, output,, dddd`, MMMM` d`, yyyy
    SendInput %output%
return

; <W-A y> => AHK Window Spy
$#!y::
	if (FileExist("C:\Program Files\AutoHotkey\AU4_Spy.exe")) {
		Run, C:\Program Files\AutoHotkey\AU4_Spy.exe
	}
	else if(FileExist("C:\Program Files\AutoHotkey\WindowSpy.ahk")) {
		Run, C:\Program Files\AutoHotkey\WindowSpy.ahk
	}
return

; converted
; Speaks given message using computer-generated voice.
speak(message) {
	return
	Global OPT_SPEAK	
	if (OPT_SPEAK) {
		ComObjCreate("SAPI.SpVoice").Speak(message)	
	}
}

; NOTE: Not migrating these date bars hotstrings. Never use them.
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

; NOTE: Not migrating Paste and Mouse Keys modes. Never use.
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

#IfWinActive ahk_group PersonalKanban

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
	color := 0 ; a sample pixel from the Blocked column
	tabColor := 0 ; a sample pixel from the first Google Sheets sheet tab
	headerY := 350 ; to detect if selected cell is in the Done column
	doneSelected := 0xE8EAEE ; pixel color if Done column selected
	doneSelected2 := 0xE8EAED ; pixel color if Done column selected
	activeTabColor := 0x1000000 ; pixel color when first Google Sheet tab is active
	hoveringOverDoneColumn := false
	doneColumnSelected := false

	if (host = "ZENBOOK") { ; ASUS Zenbook 14X OLED
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
			SetKeyDelay, 40, 20
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
			Sleep 200
			SetKeyDelay, 10, -1 ; default	

			; Copy completed tasks to progress text file using Vim.
			; file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
			file = G:\My Drive\Organization\Progress\Home\Progress (Home).txt
			Run %file%
			Sleep 200
			SetTitleMatchMode, 2
			WinActivate, GVIM
			WinWaitActive, GVIM
			Send gg
			; This is a bit weird because when you hit /, Vim advances a character, so it does not
			; find the first date line in the file.
			year := A_Year - 2001
			Send /0%year%-{Enter}
			Send o
			Send ^v
			Send {Enter}
			Send {Esc}
			Sleep 100
			Send ^s ; My Vim saves the file when this is pressed.
		}
		else { ; Marking a single task done.
			; Mark as done in Kanban sheet using Move to Done macro.
			Send ^+!0
		}
	}
	else if (activeSheet = "Recurring") {
		; Mark as done in Recurring sheet.
		SetKeyDelay, 25, 25
		Send ^b
		Send {right 5}
		Send ^;
		Send {left 5}
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
#IfWinActive

;===============================================================================
; Submodes
;===============================================================================

;-------------------------------------------------------------------------------
; <W d> => Debug mode.
$#d::
    ; SoundPlay %A_ScriptDir%\Sounds\Debug_Start.wav
    Run %A_ScriptDir%\Debug.ahk
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
		;speak("Modes window")
		return
	}

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
	
	;speak("Modes window")

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


CONVERTED

*/


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
	; speak("Reloading Modes")
    Reload

    ; This code can only be reached if reloading fails.
    Sleep 1000
    MsgBox 5, , Script reloaded unsuccessful, open it for editing?
    IfMsgBox Yes, Edit
return


