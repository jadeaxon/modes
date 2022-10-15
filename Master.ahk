; The master script loads other AHK scripts.  These are modes or contexts like in vi.
; The master script is always running.

; NOTE: This only runs on Windows Vista 1280x800 32-bit color.  No DPI scaling can be set in Windows.

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
SetTitleMatchMode, 2

Menu, Tray, Icon, %A_ScriptDir%\Icons\Master.ico

CoordMode, Mouse, Relative

; Group all Explorer windows.  Used by a shortcut to close them all.
GroupAdd, ExplorerGroup, ahk_class CabinetWClass
GroupAdd, ExplorerGroup, ahk_class ExploreWClass

; Let kanban hotkeys/hotstrings work with Firefox and Chrome.
GroupAdd, PersonalKanban, Personal Kanban ahk_class MozillaWindowClass
GroupAdd, PersonalKanban, Personal Kanban ahk_class Chrome_WidgetWin_1
GroupAdd, WorkKanban, Work Kanban ahk_class MozillaWindowClass
GroupAdd, WorkKanban, Work Kanban ahk_class Chrome_WidgetWin_1


; Is mouse click locked down via CapsLock hotkey?
mouseDownLock := false

; Have we cut a kanban item to the clipboard?
kanbanCut := false

; Are the left Control and Shift keys mapped to sending down/up keystrokes?
; Controlled by a checkbox in the Modes GUI (<A-W m>).
OPT_LEFT_SCROLL := 0

; Speak when hotkeys/hotstrings are triggered?
OPT_SPEAK := 0

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

; Context menu position for Slack reminders.
menuPosition := 0


;===============================================================================
; Includes
;===============================================================================

Run %A_ScriptDir%\AutoCorrect.ahk

#Include %A_ScriptDir%\Library.ahk
; #Include %A_ScriptDir%\Kindle.ahk
; #Include %A_ScriptDir%\JRoutine.ahk
#Include %A_ScriptDir%\PL-SQL.ahk


;===============================================================================
; Abbreviations, Hotstrings
;===============================================================================

/*
Hotstrings
*/

; Make the hotstrings case-sensitive.
#Hotstring c

; These abbreviations expand in most Windows programs.
; They do not expand in Cygwin.
::USAx::United States of America
::UVUx::Utah Valley University
::ESSx::ERP Software Services

; Some common symbols.  Copyright, registered trademark, and trademark.
::(c)::{U+00A9}
::(r)::{U+00AE}
::(tm)::{U+2122}


; In Cygwin, I use j@h as a command 99% of the time.
; How would I do ~ or / in case using absolute path?
#IfWinNotActive ahk_exe mintty.exe
:*:j@h::jadeaxon@hotmail.com
#IfWinNotActive

:*:j@g::jadeaxon@gmail.com
:*:je@g::java.emitter@gmail.com
:*:jr@u::jeffrey.anderson@uvu.edu
:*:1@u::10845493@uvu.edu
:*:j@u::jeff.anderson@uvu.edu
:*:my.uvid::10845493
:*:my.pidm::658225


; Misspellings.
::comrad::comrade
:*:digestable::digestible
:*:hazzard::hazard
:*:plateu::plateau
:*:persuassion::persuasion
:*:colocation::collocation

; Date and time.
; 9:30 AM
:*:<time>::
    FormatTime, output,, h:mm tt
    SendInput %output%
return

; 9:36 PM
:*:<t>::
    FormatTime, output,, h:mm tt
    SendInput %output%
return

; 8/11/2011 9:30 AM
:*:<ts>::
    FormatTime, output,, M/d/yyyy h:mm tt
    SendInput %output%
return

; 02/22/2O12
:*:<mdy>::
    FormatTime, output,, MM/dd/yyyy
    SendInput %output%
return

; 2017-08-12
:*:<ymd->::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%
return

; ymd => 2019-03-11: 
; For some reason, this never triggers on the first use in gVim.
; Ah, it's because without the *, it sees the i/I/o/O transition to insert mode as part of the word!
; But, I don't want a star to get the right behavior with : (which can't be used as a hotstring
; character).
::iymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%:{space}  
return

; This still doesn't work.
::Iymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%:{space}  
return

; This still doesn't work.
::Oymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput {enter}%output%:{space}  
return

; For some strange reason, we lose an enter keystroke here.
::oymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput {enter}%output%:{space}  
return

::ymd::
	FormatTime, output,, yyyy-MM-dd
	SendInput %output%:{space}  
return


; Directory abbreviation for Downloads directory.
:*:Aoddl::
:*:Acddl::
	EnvGet, vUserProfile, USERPROFILE
	Run, %vUSERPROFILE%\Downloads
	speak("Opening downloads folder")	
return

; Open a website: YouTube.
:*:Aowyt::
	Run, https://www.youtube.com
	speak("Opening YouTube")
	WinWaitActive, YouTube,, 1
	WinActivate, YouTube
return

; Open an app: Thunderbird.
:*:Aoatb::
	Run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Mozilla Thunderbird.lnk
	speak("Opening Thunderbird")
	WinWaitActive, Thunderbird,, 1
	WinActivate, Thunderbird
return

; Open Firefox.
:*:Aoaff::
	Run, "C:\Program Files\Mozilla Firefox\firefox.exe"
	speak("Opening Firefox")
	WinWaitActive, ahk_exe firefox.exe,, 1
	WinActivate, ahk_exe firefox.exe
return

; Open Chrome.
:*:Aoagc::
	Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
	speak("Opening Chrome")
	WinWaitActive, ahk_exe chrome.exe,, 1
	WinActivate, ahk_exe chrome.exe
return

; Open all your comms apps.
:*:Aoa*c::
	if (not WinExist("ahk_exe OUTLOOK.EXE")) {	
		Run, C:\Users\%A_UserName%\Desktop\Comms\Outlook.lnk
	}
	
	if (not WinExist("ahk_exe thunderbird.exe")) {
		Run, C:\Users\%A_UserName%\Desktop\Comms\Mozilla Thunderbird.lnk
	}
	
	; if (not WinExist("ahk_exe Teams.exe")) {
		Run, C:\Users\%A_UserName%\Desktop\Comms\Microsoft Teams.lnk
	; }

	; if (not WinExist("ahk_exe slack.exe")) {
		Run, C:\Users\%A_UserName%\Desktop\Comms\Slack.lnk
	; }

	speak("Opening communications apps")
	Sleep, 3000
	
	WinMaximize, ahk_exe thunderbird.exe
	Sleep, 500
	WinActivate, ahk_exe thunderbird.exe

	WinMaximize, ahk_exe Teams.exe
	Sleep, 500
	WinActivate, ahk_exe Teams.exe
	; Teams does this weird overmaximization.
	Sleep, 200
	Send #{Up}
	WinMinimize, ahk_exe Teams.exe
	
	WinMaximize, ahk_exe slack.exe
	Sleep, 500
	WinActivate, ahk_exe slack.exe
	
	Sleep, 3000 
	WinMaximize, ahk_exe OUTLOOK.EXE
	Sleep, 500
	WinActivate, ahk_exe OUTLOOK.EXE
	; Unless you end on Outlook, its tray bar lights up with alert status.
return

; This does not work.
; Has to be run as its own app.
; I can't figure out how to load it as part of this one.
; #Include %A_ScriptDir%\RegExHotstrings.ahk
; Probably because nothing autoexecutes after the first hotkey/hotstring is defined.


; A hotstring to use with @Today.txt.
:*:s.today::
    FormatTime, year,, yyyy
    FormatTime, month,, MM
    FormatTime, day,, dd
	FormatTime, day3, A_Now, ddd ; Mon, Tue, etc.

    output = %year%-%month%-%day%
    SendInput %output%: %day3%

	Send, `n`n
	Send, 5: `n
	Send, 6: `n
	Send, 7: `n
	Send, 8: `n
	Send, 9: `n
	Send, 10: `n
	Send, 11: `n
	Send, 12: `n
	Send, 1: `n
	Send, 2: `n
	Send, 3: `n
	Send, 4: `n
	Send, 5: `n
	Send, 6: `n
	Send, 7: `n

return


; These are used with items moved to Waiting column in kanban.
:*:@WW::@W: Walmart
:*:@WA::@W: Amazon


;===============================================================================
; Hotkeys
;===============================================================================

/*
Hotkeys
*/


; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

; Note that you can right click by doing a two-finger trackpad tap.
; The right click button on my laptop is not working correctly.
; Making it so that Ctrl left click does a right click.
; For some reason, if you try to map Alt left click, the context menu just closes instantly.
;
; Mostly this is okay, but it ruins the browser Ctrl click to open link in another tab.
;
; The reason it's not working is because the battery in my Dell XPS 9570 had expanded.  Fail Dell
; engineering.  I took the battery out, and now the trackpad works fine.  I just don't have a
; battery now, so I have to be careful about the laptop becoming unplugged!
; ^LButton::
;	Click, Right
; return

; Make a three-finger trackpad tap start dragging.
; PRE: Three finger tap mapped to custom shortcut <C-A-S d>.
; PRE: ClickLock is enabled in mouse settings.
; ^!+d::
;	Click down
;	Sleep 1000
;	Click up
; return


; Make CapsLock click the mouse.
$CapsLock::
	Click
return

; Make <S CapsLock> double click.
$+CapsLock::
	Click
	Sleep 20
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

; <S Numpad0> => <S Insert> on Inspiron.
; Since the Inspiron doesn't have an Insert key, and ^C doesn't work consistently everywhere,
; this is useful.
+Numpad0::
	Send +{Insert}
return

; Make page navigation easier in Adobe Digital Editions.
#IfWinActive ahk_exe DigitalEditions.exe
Down::
	Send {PgDn}
return

Up::
	Send {PgUp}
return
#IfWinActive


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
SetTitleMatchMode 2 ; Match window title internally.
#IfWinActive Wikipedia - Mozilla Firefox ahk_class MozillaWindowClass
$!r::
    Send ^l ; Select URL in Firefox.
    Clipboard := "" ; Clear the clipboard.
    Sleep 200
    Send ^c ; Copy selection.
    ClipWait ; Wait for clipboard to settle.

	; Get the article's subject.
    pos := RegExMatch(Clipboard, "/wiki/")
    pos += 6
    subject := SubStr(Clipboard, pos)
    url = http://en.wikipedia.org/w/index.php?title=%subject%&printable=yes
    Clipboard := url
    ClipWait
    Send ^l
    Send ^v
    Send {Enter}
return
#IfWinActive
SetTitleMatchMode 1


SetTitleMatchMode 2 ; Match window title internally.
#IfWinActive YouTube ahk_class MozillaWindowClass
; Allows me to use left hand to move through YouTube videos.
$a::
	CoordMode, Mouse, Window
	MouseGetPos, x, y
	if (y > 350) {
		Send {Left}
	}
	else {
		Send a
	}
return

$'::
	CoordMode, Mouse, Window
	MouseGetPos, x, y
	if (y > 350) {
		Send {Right}
	}
	else {
		Send {' down}{' up}
	}
return
#IfWinActive
SetTitleMatchMode 1


; Alternate scrolling keys so you're not always using your right hand.
; Only enabled when OPT_LEFT_SCROLL = 1.
#If (OPT_LEFT_SCROLL = 1)
$LShift::
	Send {Up 4}
return

$LControl::
	Send {Down 4}
return
#If

; Makes <C-A g> search selected text in Google.
; This kind of thing is also in Navigation mode.
$^!g::
	; Beware that <C-S c> opens Inspector in Firefox.
	Clipboard := ""
	Send, ^c
	Sleep, 200
	; Remove the citation cruft Kindle adds.
	loop, Parse, Clipboard, `n, `r
	{
		Clipboard := A_LoopField
		break
	}
	Run, http://www.google.com/search?hl=en&q=%Clipboard%
return


$^!l::
    ; Send ^!{Delete}
    ; Send ^!{vk2Esc153} ; This lets you lock the screen.
    Run taskmgr
return

; Before locking the screen, mute the volume.  This is so Slack alerts don't bother other people at work.
$#l::
    Send {Volume_Mute}
    ; Windows will respond to the <W l> also.  This does not block Windows from seeing it.
return


; Make it so I can launch Launchy from the VM.
; This does not work.
#IfWinActive ahk_class VMPlayerFrame
$!space::
    Send {Ctrl Right}{Alt Right}
    Send !{Space}

return
#IfWinActive


; Make it so SlickRun dismisses by <A-r>.
#IfWinActive ahk_class TMain
$!r::
    Send {Esc}
return
#IfWinActive


;-------------------------------------------------------------------------------
; Make it easy to archive message being viewed in Hotmail.
; Note that in Hotmail, <C .> moves to next message and <C ,> moves to previous message.
; These are both close to the 'e' key in Programmer Dvorak.  So, using these three shortcuts
; is great for processing your @Waiting folder during a GTD weekly review.
#IfWinActive Mail - jadeaxon@hotmail.com ahk_class MozillaWindowClass
; Use 'e' to archive.  This is built into Hotmail.

$^.::
	; Move to next message.
	Send ^.
	Sleep 300
	; Select the message pane so you can scroll the (usu Amazon shipping) message.
	Send {Tab}

return

$^,::
	; Move to previous message.
	Send ^,
	Sleep 300
	; Select the message pane so you can scroll the (usu Amazon shipping) message.
	Send {Tab}

return
#IfWinActive


; Make <C @> move selected/current message to @Waiting in Hotmail.
#IfWinActive Mail - jadeaxon@hotmail.com ahk_class MozillaWindowClass
$^@::
	Send v ; This shortcut is built into Hotmail for moving messages.  Pops up dialog.
	Sleep 200
	; Adding my new @Dropped folder broke this.
	; Once again, the Outlook webapp is brain dead.  It only sees the first letter typed into the
	; search box when activated via v!  	
	; Send @Waiting{Enter}
	Send @{down}{enter}
return
#IfWinActive



; A2  01D	 	d	2.83	LControl
; 31  002	 	d	0.28	1
; 31  002	 	u	0.09	1
; A2  01D	 	u	0.08	LControl
; A2  01D	 	d	0.64	LControl
; 32  003	 	d	0.34	2
; 32  003	 	u	0.11	2
; A2  01D	 	u	0.06	LControl

; DB  002	 	u	0.13	&
; 37  003	 	d	0.55	[
; Remap <C 1> and <C 2> to switch between mail and calendar.  These get messed up since Programmer
; Dvorak uses symbols on the number key row.
^SC002::
	; <C &> => <C 1>
	Send {vkA2sc01D Down}{vk31sc002 Down}{vk31sc002 Up}{vkA2sc01D Up}
return

^SC003::
	; <C [> => <C 2>
	Send {vkA2sc01D Down}{vk32sc003 Down}{vk32sc003 Up}{vkA2sc01D Up}
return



; FAIL: Keyboard shortcuts in Chrome don't work when using Programmer Dvorak!
; Chrome sees <C-+> as <C-4>.  Can't figure out how to fix.
#IfWinActive ahk_class Chrome_WidgetWin_1
$^4::
    MsgBox,, Hi
    Send ^+
return
#IfWinActive


/*
; FAIL: Emoji popup.  Use Esc to dismiss it.
; Esc should dismiss it.
; Also, there's a Windows setting which dismisses the Emoji Panel after an
; emoji is emitted.
#IfWinActive ahk_class ApplicationFrameWindow ahk_exe Explorer.EXE
Esc::
	; Send {enter}{backspace}
	; Send #.
return
#IfWinActive
*/


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

/*
Outlook
*/

; Archive the message your mouse is hovered over.  In Outlook's Inbox.
; FAIL: It changes last moved-to folder to top of list, so can't use fixed position!
; WIN: Set up a "Quick Step" in Outlook with shortcut key of <C-S 1>.  You can't set <C a> as shortcut there, so you remap it here.
#IfWinActive - Jeff.Anderson@uvu.edu - Outlook
$a::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+1
	}
	else {
		Send a
	}
return


; b => quick action #2 => move to latest Banner upgrade folder and mark read
$b::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+2
	}
	else {
		Send b
	}
return


; w => quick action #3 => move to @Waiting and mark read
$w::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+3
	}
	else {
		Send w
	}
return


; s => quick action #4 => move to @Parent Child Sync and mark read
$s::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+4
	}
	else {
		Send s
	}
return


; u => quick action #5 => move to @Exec Midyear Check-In and mark read
$u::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+5
	}
	else {
		Send u
	}
return


; o => quick action #6 => move to @OBES and mark read
$o::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+6
	}
	else {
		Send o
	}
return


; i => quick action #7 => move to Inbox and mark read
$i::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+7
	}
	else {
		Send i
	}
return

; e => quick action #8 => move to @ESS and mark read
$e::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send ^+8
	}
	else {
		Send e
	}
return

#IfWinActive

; Makes <C w> close Outlook.
#IfWinActive ahk_exe OUTLOOK.EXE
^w::
	Send !{F4}
return
#IfWinActive

; Make d delete messages in Outlook inbox.
#IfWinActive - Jeff.Anderson@uvu.edu - Outlook
$d::
	; This is the value of ClassNN in Window Spy.
	ControlGetFocus, widget, A
	; MsgBox,,, %widget%
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		Send {AppsKey}k{Esc}
		Send {delete}
	}
	else {
		Send d
	}
return
#IfWinActive


; Make r mark folder read for any folder.
; Make r mark selected message read.
#IfWinActive - Jeff.Anderson@uvu.edu - Outlook
$r::
	; Get the control under the mouse.  It may not have the focus yet.
	MouseGetPos,,,, widget
	if (widget = "NetUIHWND4") {
		Click
		Sleep 200
	}
	
	ControlGetFocus, widget, A
	if (widget = "NetUIHWND4") {
		; Open the context menu.
		; SendInput {AppsKey}
		SendInput, +{F10}
		Sleep 300
		; Mark folder as read.
		SendInput e
	}
	else if (RegExMatch(widget, "^OutlookGrid\d$")) {
		SendInput, +{F10} ; Open the context menu.
		Sleep 300
		SendInput k ; Mark message as read.
	}
	else {
		Send r
	}
return

; Make R reply to all.
$+r::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		SendInput, +{F10}
		Sleep 100
		; Two context menu items have the same accelerator key, so you have to hit enter.
		SendInput A{Enter} ; Reply all.
	}
	else {
		SendInput R
	}
return
#IfWinActive


; Make f flag messages in Outlook.
; Make F clear the flag.
#IfWinActive - Jeff.Anderson@uvu.edu - Outlook
$f::
	; This is the value of ClassNN in Window Spy.
	ControlGetFocus, widget, A
	; MsgBox,,, %widget%
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		SendInput, +{F10}
		Sleep 100
		SendInput u ; Follow up.
		Sleep 100
		SendInput t ; Today.
	}
	else {
		Send f
	}
return

$+f::
	ControlGetFocus, widget, A
	if (RegExMatch(widget, "^OutlookGrid\d$")) {
		SendInput, +{F10}
		Sleep 100
		SendInput u ; Follow up.
		Sleep 100
		SendInput e ; Clear flag.
	}
	else {
		Send +f
	}
return
#IfWinActive


;==============================================================================
; Gmail
;==============================================================================


#IfWinActive Inbox - jadeaxon@gmail.com
$^`::
	Send ^l
	Sleep 300
	SendRaw https://mail.google.com/mail/u/1/#inbox
	Send {enter}
return

#IfWinActive

#IfWinActive Inbox - java.emitter@gmail.com
$^`::
	Send ^l
	Sleep 300
	SendRaw https://mail.google.com/mail/u/0/#inbox
	Send {enter}
return
#IfWinActive

;-------------------------------------------------------------------------------
; Steam

; Make Steam Discovery Queue not suck.
; PRE: Fullscreen Firefox with no zoom factor on 4K XPS15-9570 4K.
#IfWinActive on Steam ahk_class MozillaWindowClass
$^n::
	; Ignore.  The button is not consistently in the same place.
	; I don't want to resort to computer vision or figuring out user scripts fOr Greasemonkey yet.
	; I guess really I just need to read a single pixel color and only click if it matches.
	MouseMove, 1466, 1878
	Click
    MouseMove, 1462, 1777
	Click
	Sleep 750
	MouseMove, 2924, 1873
	Click
	MouseMove, 2927, 1769
	Click
return

#IfWinActive

; FAIL: For some reason, this does not work in the Steam client.
#IfWinActive ahk_exe Steam.exe
$^n::
	; Ignore.
    MouseMove, 1470, 1879
	Click
	Sleep 750
	MouseMove, 2927, 1871
	Click
return
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
	Sleep 200
	; Mark folder as read.
	SendInput k
return

#IfWinActive

; Make d act like delete key.
#IfWinActive Junk - Mozilla Thunderbird
$d::
	Send {delete}
return


; Run all the filters on the Junk folder.
$f::
	; MsgBox,,, Here
	Send {LAlt down}
	Sleep 200
	Send {LAlt up}
	Sleep 100
	Send t
	Sleep 200
	Send R
return


; Add a new junk mail filter for this message.
$j::
	EnvGet, host, COMPUTERNAME
	; Open message in new tab.
	Click
	Click
	; Copy email address.
	CoordMode, Mouse, Window
	if (host = "L16382") { ; Surface Pro 8
		MouseMove, 125, 165
	}
	else if (host = "Inspiron-VM") {
		MouseMove, 70, 85
	}
	Sleep 200
	Click
	Sleep 100
	Send C
	Sleep 100
	ClipWait	
	Send ^w
	; Open mail filters.
	Send {LAlt down}
	Sleep 200
	Send {LAlt up}
	Send t
	Sleep 100
	Send F
	Sleep 100
	; Add email address to Junk #1 filter.
	; Relies on it being the 3rd filter.
	SetKeyDelay, 50, 25
	Send {Down 2}
	Send !e
	Send {Tab 12}
	Send {Enter}
	Send +{Tab}+{Tab}+{Tab}
	Send ^v
	Send {Enter}
	Send {Esc}
	SetKeyDelay, 10, -1 ; default
return


#IfWinActive

; Make d act like delete key.
#IfWinActive Inbox - Mozilla Thunderbird
$d::
	Send {delete}
return
#IfWinActive

; Make d act like delete key.
#IfWinActive @Waiting - Mozilla Thunderbird
$d::
	Send {delete}
return
#IfWinActive


; w => Move message to @Waiting.
#IfWinActive Inbox - Mozilla Thunderbird
$w::
	Send {alt down}
	Sleep 40
	Send {alt up}
	Sleep 100
	Send mmj
	Sleep 50
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send {enter}
return
#IfWinActive

; w => Move message to @Waiting.
#IfWinActive Junk - Mozilla Thunderbird
$w::
	Send {alt down}
	Sleep 40
	Send {alt up}
	Sleep 100
	Send mmj
	Sleep 50
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send @
	Sleep 40
	Send {enter}
return
#IfWinActive


; i => Move message to Inbox.
#IfWinActive Junk - Mozilla Thunderbird
$i::
	Send {alt down}
	Sleep 20
	Send {alt up}
	Sleep 100
	Send mmj@
	Sleep 50
	Send i
	Sleep 50
	Send {enter}
	
return
#IfWinActive



;-------------------------------------------------------------------------------
; Hotmail <C-n> opens new Firefox window as it should.  Stupid Hotmail overrode browser default shortcut.
#IfWinActive Hotmail ahk_class MozillaWindowClass
$^n::
    ; For whatever bizarre reason, unless I show a message box, the Alt key won't activate menu bar.
    ; MsgBox,,, Opening new window., 1
    ; {LAlt}
    ; Send {vkA4sc038}
    ; However, this SendEvent somehow does work.
    ; Menu Bar|File|New Window.
    SendEvent !F
    Sleep 200
    Send N

return
#IfWinActive


; Define hotstrings for common person tasks.
; BUG: For some reason, any hotstring with s or w in it is not working.
; I moved some of the hotstrings into RegExHostrings.ahk as a workaround.
#IfWinActive ahk_group PersonalKanban
:*c:Tlt::Laundry (whites) [rD1] {enter}
:*c:Tlw::Laundry (whites) [rD1] {enter}
:*c:TAh::Air out house [H1]{enter}
:*c:TOo::Overnight oats [H1]{enter}
:*c:Tt::Trash [rD1]{enter}
:*c:Tbt::Big trash [rD1]{enter}
:*c:Tld::Laundry (darks) [rD1]{enter}
:*c:Tlm::Laundry (mfcs) [rD1]{enter}
:*c:Tlo::Laundry (other) [rD1]{enter}
:*c:Td::Dishes [rD1]{enter}
:*c:Trb::Reset buffers [rD1]{enter}
:*c:Tg::Guitar [rRK1]{enter}
:*c:TEl::Elliptical [rH1]{enter}
:*c:Tfm::Fresh Market [rD1]{enter}
:*c:Tc::Cleaning [rDM1]{enter}
:*c:T7::GTD7 [rK1]{enter}
:*c:Tk::kbs 100 [rH1]^{enter}0{enter}
:*c:Tbh::Bar hang [H1]^{enter}


; Never paste formatting.  Otherwise column background colors get screwed up.
$^v::
	; The problem with this is now if you paste any multiline cell, it pastes it as multiple cells.
	; clipboard := trim(clipboard, """") ; Remove outer double quotes.
	Send ^+v
return

$^x::
	SendInput ^c
	Sleep 50
	SendInput {delete}
	Sleep 50
	SendInput {backspace}
return

; #HotkeyModifierTimeout 0

; Use with recurring tasks sheet.  When in the first cell of the task.
; <C d> marks as done (unbolds and sets last done as current date).
$^d::
	activeMonitor := activeMonitorName()
	CoordMode, Mouse, Window
	CoordMode, Pixel, Window
	EnvGet, host, COMPUTERNAME
	SysGet, monitors, MonitorCount
	color := 0
	tabColor := 0
	headerY := 350

	if (host = "L16382") { ; Surface Pro 8
		if (activeMonitor = "Surface Pro 8") { ; The laptop's screen.
			; This is for running Surface without external monitors.
			PixelGetColor, color, 2759, 446

			; This position is on the bottom Kanban sheet tab.
			; When a sheet is selected, the pixels other than the sheet name are white.
			if (monitors = 1) {
				PixelGetColor, tabColor, 260, 1800
			}
			else { ; Multiple monitors.
				PixelGetColor, tabColor, 130, 940
			}
		}
		else if (activeMonitor = "LG UltraFine") { ; LG UltraFine
			PixelGetColor, color, 1387, 224
			PixelGetColor, tabColor, 130, 1420
		}
		else if (activeMonitor = "Dell") {
			PixelGetColor, color, 1386, 223
			PixelGetColor, tabColor, 130, 1380
		}
		else { ; Unknown monitor.
			color := 0
		}
	}
	else if (host = "Inspiron-VM") {
		PixelGetColor, color, 1180, 230, RGB
		PixelGetColor, tabColor, 130, 1030, RGB
		headerY := 180
		; headerColor := 0xE8EAED
	}
	else if (host = "D309552A") { ; Lenovo ThinkCentre 910s
		PixelGetColor, color, 1380, 230, RGB
		PixelGetColor, tabColor, 130, 1140, RGB
		headerY := 180
	}
	
	; MsgBox,,, %host% %activeMonitor% %color% %tabColor%
	; return

	; The shade of red reported seems to depend on the monitor.
	if ((color = 0xCDCDF2) or (color = 0xCCCCF4) or (tabColor = 0xFFFFFF)) {
		MouseGetPos, mx, my
		PixelGetColor, color, mx, my, RGB
		PixelGetColor, color2, mx, headerY, RGB ; Detect if a cell in the Done column is selected.	
		; MsgBox,,, %mx%, %my%, %color%

		if ( ((color = 0xDAEAD4) or (color = 0xD9EAD3)) and (color2 = 0xE8EAED) ) {
			; We're hovering in the (green) Done column.
			; Assume over the top non-header cell.
			SetKeyDelay, 40, 20
			Send, {LShift Down}
			Send, {Down 6}
			Send, {LShift Up}
			Send ^c
			ClipWait	
			Send {Backspace}
			Send {Delete} ; First one doesn't always do it.
			Sleep 200
			SetKeyDelay, 10, -1 ; default

			; Copy completed tasks to progress text file using Vim.
			file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
			Run %file%
			Sleep 200
			SetTitleMatchMode, 2
			WinActivate, GVIM
			WinWaitActive, GVIM
			Send gg
			; This is a bit weird because when you hit /, Vim advances a character, so it does not
			; find the first date line in the file.
			year := A_Year - 2000
			Send /0%year%-{Enter}
			Send o
			Send ^v
			Send {Enter}
			Send {Esc}
			Send ^s ; My Vim saves the file when this is pressed.
		}
		else { ; Marking a single task done.
			; Mark as done in Kanban sheet using Move to Done macro.
			Send ^+!2
		}
	}
	else {
		; Mark as done in Recurring sheet.
		SetKeyDelay, 25, 25
		Send ^b
		Send {right 5}
		Send ^;
		Send {left 5}
		SetKeyDelay, -1, -1
	}
return

; Sort by Score descending.
; I end up doing this a lot after marking items as done or at the start of each new day.
; I recorded a macro in Google Sheets that does this when you press <C-A-S 1>.
; This just makes <C s> trigger it instead.
$^s::
	activeMonitor := activeMonitorName()
	CoordMode, Mouse, Window
	CoordMode, Pixel, Window
	SysGet, monitors, MonitorCount

	; TO DO: Factor this into a function that returns name of active Google Sheet.
	tabColor := 0
	EnvGet, host, COMPUTERNAME
	if (host = "L16382") { ; Surface Pro 8
		if (activeMonitor = "Surface Pro 8") { ; The laptop's screen.
			; This position is on the bottom Kanban sheet tab.
			; When a sheet is selected, the pixels other than the sheet name are white.
			if (monitors = 1) {
				PixelGetColor, tabColor, 460, 1800, RGB
			}
			else { ; Multiple monitors.
				PixelGetColor, tabColor, 230, 940, RGB
			}
		}
		else if (activeMonitor = "LG UltraFine") { ; LG UltraFine
			PixelGetColor, tabColor, 225, 1420, RGB
			if (tabColor != 0xFFFFFF) {
				; Some of the pixels aren't pure white.
				PixelGetColor, tabColor, 226, 1422, RGB
			}
		}
		else if (activeMonitor = "Dell") {
			PixelGetColor, tabColor, 240, 1380, RGB
		}
		else { ; Unknown monitor.
			color := 0
		}
	}
	else if (host = "Inspiron-VM") {
		PixelGetColor, tabColor, 230, 1032, RGB
	}
	
	; MsgBox,,, %activeMonitor% %color% %tabColor%
	; return

	if (tabColor = 0xFFFFFF) { ; Light gray of header row on Recurring sheet.
		; Run the app script to sort sheet by Score column.
		Send ^+!1
	}
return

; Show info about all monitors.
$^m::
	activeMonitor := activeMonitorName()
	MsgBox,,, %activeMonitor%
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

; <A click> toggles between cut and paste.
; All the normal modifier keys cause unwanted side behavior.
/*
Esc & LButton::
	Click
	Sleep 20
	if (!kanbanCut) {
		SendInput ^c
		Sleep 50
		SendInput {delete}
		Sleep 50
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
	file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
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
	Sleep 50
	SendInput {delete}
	Sleep 50
	SendInput {backspace}
return


; <A click> toggles between cut and paste.
; All the normal modifier keys cause unwanted side behavior.
/*
Esc & LButton::
	Click
	Sleep 20
	if (!kanbanCut) {
		SendInput ^c
		Sleep 50
		SendInput {delete}
		Sleep 50
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

; <A p> => Transition to progress file from kanban.
$!p::
	file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\UVU\%A_YYYY%\Progress (UVU).txt
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
; Vaio Laptop and Dell XPS 410.
; A0  02A	 	d	0.03	Left Shift
; 2D  152	 	d	0.02	Insert
; 2D  152	 	u	0.09	Insert
; A0  02A	 	u	0.14	Left Shift
; $^k::
    ; ; TO DO: This does not work on my Windows 7 64-bit workstation.
    ; WinGetClass, class, A
    ; if (class = "mintty") {
        ; ; Apparently, {Insert} does not map to the insert key on my Vaio laptop.
        ; ; Send {vkA0sc02A Down}{vk2Dsc152}{vkA0sc02A Up}
        ; Send +{vk2Dsc152}
    ; }
    ; else { ; Not mintty.
        ; Send ^v
    ; }
; 
; 
; return


;-------------------------------------------------------------------------------
; PyCharm
#IfWinActive ahk_exe pycharm64.exe

; Compensate for Programmer Dvorak weirdness.
; What AHK sees as <A [>, PyCharm sees as <A 7>.  What I'm trying to press is <A 2>.
; You'd need to press shift to get 2 in Programmer Dvorak, but that messes it up somehow.
; ![:: -- Nope, AHK can't see this.
$!sc003::
	; The problem is, AHK has to use an alternate method of sending <A 2> since that combination
	; actually is not possible in Programmer Dvorak.
	; Since what it sends is not a key event, it can't trigger shortcut behavior.
	; Send !2

	; Watching its Keymap, PyCharm thinks you've hit <A 2> when you hit <A )> and emit that virtual key.
	; WORKS!
	Send !{vk32sc009}

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
    ; On Windows 7 machine, it is the same.
    Send +{vk2Dsc152}

    ; Click Right
    ; Sleep 10
    ; Send {Down}
    ; Sleep 10
    ; Send {Enter}

return

#IfWinActive


;-------------------------------------------------------------------------------
; Make <Ctrl + W> close PuTTY windows (so your tabbed-browsing moves work everywhere).
#IfWinActive ahk_class PuTTY
$^w::
    WinClose A
    Sleep 20
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
; <Alt + F1> => look up AutoHotkey docs (when we're editing .ahk files in Cygwin)
; <A-W h> => ditto

!#h::
!F1::
	; MsgBox,,, Triggered
	GoSub, GetAutoHotkeyHelp
return

GetAutoHotkeyHelp:
	topic := Clipboard
	Run, https://www.autohotkey.com/docs/%topic%
	speak("Autohotkey help")
	Sleep 500
	WinActivate, ahk_exe firefox.exe
return


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
;    Send +{vk2Dsc152}

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
	Sleep 500
	Send {Tab}{Tab}{Enter} ; Open dialog to choose folder.
	Sleep 200
	Send n ; Choose bookmarks toolbar N folder.
	Sleep 200
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
	if (A_PriorHotkey = W_HOTKEY) && (A_TimeSincePriorHotkey <= 500) {
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
; Keyboard
;==============================================================================


;-------------------------------------------------------------------------------
; Remap {Left} to my keyboard's left arrow.
; {Left} => Numpad4 on this laptop for some reason.
;
; Without doing this, automating context menus doesn't work.
VK64::
    Send, {vk25sc14B}
return

; Remap {Down} to my keyboard's down arrow
VK68::
    Send, {vk28sc150}
return

; {vk27sc14D} => right arrow


;-------------------------------------------------------------------------------
; Make h => {Down} and l => {Up} in Sumatra PDF Reader
; This could be a problem if I type something in a search field or whatnot.
#IfWinActive ahk_class SUMATRA_PDF_FRAME
$l::
    Send {vk26sc148}
return

$h::
    Send {vk28sc150}
return

#IfWinActive


;==============================================================================
; Windows Explorer
;==============================================================================

;-------------------------------------------------------------------------------
; Open command prompt at current folder in Explorer.
; <Ctrl + Alt + c> in Windows Explorer.
; http://lifehacker.com/5306401/open-a-new-command-prompt-from-explorer-with-a-hotkey
#IfWinActive ahk_class CabinetWClass ; Only applies to Explorer.
$^!c::
    ClipSaved := ClipboardAll
    Send !d
    Sleep 10
    Send ^c
    ClipWait, 2
    if ErrorLevel {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    } ; if

    Run, cmd /K "cd `"%clipboard%`""
    Clipboard := ClipSaved
    ClipSaved =
return

; Closes all Explorer windows when <A-S F4> pressed.
!+F4::
	if ( WinExist("ahk_group ExplorerGroup") )
	WinClose,ahk_group ExplorerGroup
return

; <A d> => new directory in Windows Explorer.
$!d::
	Send ^+n
	; Send +{F10}wf
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


;-------------------------------------------------------------------------------
; Gets rid of citation crap when copying from Kindle.
; BUG: Only works if copying a single line.
; TO DO: Have it just chuck the last two lines instead of only keeping the first.
; <C-c> in Kindle.
#IfWinActive ahk_class QWidget
$^c::
    Send ^c
    ClipWait, 2
    contents := Clipboard

    fixed =
    count = 0
    Loop, parse, contents, `n
    {
        ; MsgBox,,,%A_LoopField% %count% %contents%
        ; MsgBox,,,%A_LoopField%
        count += 1
        if (count == 1) {
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
	OPT_SPEAK := 1
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
    if (host = "XPS15") {
        x := 380
        y := 280
    }
    else if (host = "INSPIRON") {
        ; Something is wrong.  Coordinates displayed by Window Spy do not match.
        ; Is it a Windows DPI thing?
        ; Yes, I have Control Panel | Display | Change size of all items | 150%.
        ; AHK reports the now translated coordinates, but Windows expects the translated coordinates.
        s := 1.5
        x := 400 * s
        y := 290 * s
    }
    else {
        MsgBox,,Error, Unrecognized host.
        return
    }

    Send ^c
    ClipWait, 2
    contents := Clipboard

    fixed =
    count = 0
    Loop, parse, contents, `n
    {
        ; MsgBox,,,%A_LoopField% %count% %contents%
        ; MsgBox,,,%A_LoopField%
        count += 1
        if (count == 1) {
            fixed = %A_LoopField%
        }

    }

    StringReplace, fixed, fixed, `n, , All
    StringReplace, fixed, fixed, `r, , All
    StringReplace, fixed, fixed, "·", , All
    ; Get rid of accent marks.
    fixed2 := RegExReplace(fixed, "[^abcdefghijklmnopqrstuvwxyz]", "")
    fixed := fixed2
    Clipboard := fixed

    Run http://www.google.com
    WinWait, Google - Mozilla Firefox
    WinWaitActive, Google - Mozilla Firefox
    Send define %fixed%
    Send {Enter}
    Sleep 2000
    MouseMove, x, y
    Click 2
    Send {Tab}
    Sleep 200
    Click 2
    Send {Tab}
    Send {Enter}


return
#IfWinActive

; TO DO: Can we factor all these <C w> things down?
#IfWinActive Jeff's Kindle
; Makes <C w> close Kindle app.
^w::
	Send !{F4}
return
#IfWinActive

#IfWinActive ahk_exe Discord.exe
; Makes <C w> close Discord.
^w::
	Send !{F4}
return
#IfWinActive

#IfWinActive Weather
; Make <C w> close the Windows Weather app.
^w::
	Send !{F4}
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
    Sleep 10
    ; Copy the path.
    Send ^c
    Sleep 10
    ClipWait, 2
    if ErrorLevel {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    } ; if

    ; Run Cygwin.
    Run, C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -
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
    ; Run C:\Windows\System32\cmd.exe /K "cd %HOMEDRIVE%%HOMEPATH%"
    Run C:\Users\Jade Axon\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\Command Prompt.lnk
return


;-------------------------------------------------------------------------------
; Allow normal pasting in Command Prompt.
; Checks for Command Prompt.  <Ctrl + v> => Send the raw clipboard data.
#IfWinActive ahk_class ConsoleWindowClass
$^v::
    SendInput {Raw}%clipboard%
return

; Dvorak.  The automapping fails here.
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

; Do not Dvork 0 => Qwerty S in gVim.
; <Ctrl + O> in gVim undoes last movement command, restoring cursor position.
; Well, that's not exactly what the command does.  But it is like a back button
; of some sort.
#IfWinActive ahk_class Vim
$^o::
    Send ^o
return
#IfWinActive




;-------------------------------------------------------------------------------
; <Ctrl + Alt + F> => Firefox (well, default browser).

$^!f::
    Run http://www.google.com
return



;===============================================================================
; RoboForm

; Make it so that <C-w> closes the form filler popup.
#IfWinActive AutoFill - RoboForm
$^w::
    Send !{F4}
return
#IfWinActive



;===============================================================================
; Teams

; <C-S s> => open saved messages
#IfWinActive ahk_exe Teams.exe 
$^+s::
	; Open command bar.
	Send ^e
	Sleep 100
	; Open saved messages.
	Send /
	; If you don't pause here, Teams thinks you are searching for '/saved'.
	Sleep 200
	Send saved
	Sleep 100
	Send {enter}
return


;===============================================================================
; Slack
;===============================================================================

; Map <A S Down> to <A S n>.  <A S Down> is too hard to reach.  It is the Slack
; keyboard shortcut to change to the next channel with an unread message in it.
;
; Of course, of course, this keystroke triggered a touchpad diagnostic log dump (!),
; so I had to disable that with this:
; reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SynTP\Parameters\Debug /v DumpKernel /d 00000000 /t REG_DWORD /f
#IfWinActive ahk_exe slack.exe 
$!+n::
	; <A S Down>
	; For some reason {Down} doesn't work on this machine.
	Send !+{vk28sc150}
return

; Use <C n> as alternate.  Since I have <C h> for my "you" channel.
$^n::
	Send !+{vk28sc150}
	; If the channel has gotten a bunch of traffic, it won't be scrolled to the end.
	; This might induce you to respond to an older message (which might confuse people).
	Sleep 200
	Send {PgDn}
	Send {PgDn}
return


; Block whatever global handler is intercepting this.
; I think it was triggering my <W m> thing that keeps Outlook, etc. on a specific monitor.
$^+m::
	Send ^+m
return


; <C h> to jump to my "you" channel.
$^h::
	; Open the quick channel switcher.
	Send ^t
	Sleep 100
	; Search for the "you" channel.
	; Might not work if a strangely named channel exists.
	Send you
	; Give time for word to show up on slower Windows VM.
	; Partial search for "yo" yielded chris.young.
	Sleep 50
	Send {Enter}
return

; jj => <C j>
:*:jj::
	Send ^j
return

; Ar7 => set weekly recurring reminders
; Slack has recurring reminders, but they are implemented badly.
; I want them to spawn as individual reminder instances that I can snooze
; and mark as complete.
:*:Ar7::
	; Guard against accidental triggering when trying to do Ar5.
	; 5 and 7 are right next to each other on the Programmer Dvorak keyboard layout.
	MsgBox % 4 + 32 + 256, , Set all weekly reminders?
    IfMsgBox No, return

	
	; Monday ----------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Monday")
	remind("check calendar, set alarms, @<Day> -> Inbox at 5 AM on Monday")
	remind("check recurring tasks spreadsheet at 5 AM on Monday")
	remind("water plants at 5 AM on Monday")
	remind("waiting/blocked on @Waiting.txt/email/bookmarks/kanban/Jira/Planner at 5 AM on Monday")
	remind("check work email @Later at 5 AM on Monday")
	remind("check saved Teams messages at 5 AM on Monday")
	remind("review all work contexts and agendas at 5 AM on Monday")
	remind("read next UVU policy at 5 AM on Monday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Monday")
	remind("check unassigned ESS tickets https://uvu-it.atlassian.net/issues/?filter=11220 at 5 AM on Monday")	
	remind("do --weekly-- commitments check at 5 AM on Monday")
	remind("check https://itops.uvu.edu/secure/change_calendar/index.php page at 5 AM on Monday")
	remind("check ESS incidents https://uvu-it.atlassian.net/issues/?filter=10921 at 5 AM on Monday")
	remind("check 0 and N bookmarks at 5 AM on Monday")
	remind("do symbolic poses at 5 AM on Monday")
	remind("brush teeth at 3 PM on Monday")
	remind("check fridge and freezers at 8 PM on Monday")
	; Tuesday ---------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Tuesday")
	remind("check calendar, set alarms, @<Day> -> Inbox at 5 AM on Tuesday")
	remind("check recurring tasks spreadsheet at 5 AM on Tuesday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Tuesday")
	remind("check unwatched UPM tickets (Kahoa) https://solutionstream.atlassian.net/issues/?filter=13388 at 5 AM on Tuesday")
	remind("check unwatched UVP tickets (UVU) https://uvu-it.atlassian.net/issues/?filter=11405 at 5 AM on Tuesday")
	remind("check 0 and N bookmarks at 5 AM on Tuesday")
	remind("take magnesium at 9 AM on Tuesday")
	remind("update ESS items on https://uvu-it.atlassian.net/projects/CA/board page at 2 PM on Tuesday")
	remind("brush teeth at 3 PM on Tuesday")
	remind("check fridge and freezers at 8 PM on Tuesday")
	; Wednesday -------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Wednesday")
	remind("check calendar, set alarms, @<Day> -> Inbox at 5 AM on Wednesday")
	remind("check recurring tasks spreadsheet at 5 AM on Wednesday")
	remind("do 34 kbs at 5 AM on Wednesday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Wednesday")
	remind("check tickets reported by ESS https://uvu-it.atlassian.net/issues/?filter=11212 at 5 AM on Wednesday")
	remind("check 0 and N bookmarks at 5 AM on Wednesday")
	remind("check mail at 3 PM on Wednesday")
	remind("brush teeth at 3 PM on Wednesday")	
	remind("check fridge and freezers at 8 PM on Wednesday")
	; Thursday --------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Thursday")
	remind("check calendar, set alarms, @<Day> -> Inbox at 5 AM on Thursday")
	remind("check recurring tasks spreadsheet at 5 AM on Thursday")
	remind("prep for ESS meeting at 5 AM on Thursday")
	remind("begin GTD7 at 5 AM on Thursday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Thursday")
	remind("check unwatched UPM tickets https://solutionstream.atlassian.net/issues/?filter=13388 at 5 AM on Thursday")
	remind("check unwatched UVP tickets (UVU) https://uvu-it.atlassian.net/issues/?filter=11405 at 5 AM on Thursday")
	remind("check 0 and N bookmarks at 5 AM on Thursday")
	remind("submit Walmart order at 5 AM on Thursday")
	remind("take magnesium at 9 AM on Thursday")
	remind("brush teeth at 3 PM on Thursday")
	remind("check fridge and freezers at 8 PM on Thursday")
	; Friday ----------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Friday")
	remind("check calendar, set alarms, @<Day> -> Inbox at 5 AM on Friday")
	remind("check recurring tasks spreadsheet at 5 AM on Friday")
	remind("update Banner releases master spreadsheet at 5 AM on Friday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Friday")
	remind("check unwatched reported by me https://uvu-it.atlassian.net/issues/?filter=11028 at 5 AM on Friday")
	remind("check 0 and N bookmarks at 5 AM on Friday")
	remind("do hbands at 6 AM on Friday")
	remind("use up existing food at 9 AM on Friday")
    remind("proc all meeting notes --this-week-- (check calendar) at 1 PM on Friday")
	remind("do weekly status report (email Dave) at 3 PM on Friday")
	remind("start next Progress (UVU).txt weekly header at 3 PM on Friday")
	remind("brush teeth at 3 PM on Friday")
	remind("check unwatched ESS board tickets https://uvu-it.atlassian.net/issues/?filter=10947 at 4 PM on Friday")
	remind("check unassigned ESS board tickets https://uvu-it.atlassian.net/issues/?filter=11004 at 4 PM on Friday")
	remind("check fridge and freezers at 8 PM on Friday")
	; Saturday --------------------------------------------------------------------	
	remind("follow R1 Daily.txt at 5 AM on Saturday")
	remind("check recurring tasks spreadsheet at 5 AM on Saturday")
	remind("sync calendars at 5 AM on Saturday")
	remind("take Epsom or ACV bath at 5 AM on Saturday")
	remind("clean laptop monitors at 5 AM on Saturday")
	remind("check air filters running at 5 AM on Saturday")
	remind("listen to audiobook while bringing in groceries at 5 AM on Saturday")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Saturday")
	remind("brush teeth at 3 PM on Saturday")
	remind("check fridge and freezers at 8 PM on Saturday")
	; Sunday ----------------------------------------------------------------------	
	remind("follow R1 Daily.txt next Sunday at 5 AM")
	remind("check recurring tasks spreadsheet next Sunday at 5 AM")
	remind("respawn weekly reminders via Ar7 next Sunday at 5 AM")
	remind("reset buffers next Sunday at 5 AM")
	remind("check mail next Sunday at 5 AM")
	remind("do hbands next Sunday at 5 AM")
	remind("do 34 kbs next Sunday at 5 AM")
	remind("check unwatched ESS tickets https://uvu-it.atlassian.net/issues/?filter=10916 at 5 AM on Sunday")
	remind("brush teeth at 3 PM on Sunday")
	remind("check fridge and freezers at 8 PM on Sunday")
return


; Ar31 => set monthly recurring reminders
; Slack has recurring reminders, but they are implemented badly.
; I want them to spawn as individual reminder instances that I can snooze
; and mark as complete.
:*:Ar31::
	remind("pay Jason on the 1st of next month at 5 AM")
	remind("save/invest on the 1st of next month at 5 AM")
	remind("cycle food delivery on the 8th of next month at 5 AM")
	remind("respawn monthly reminders via Ar31 on the 25th of next month at 5 AM")
	remind("do monthly status report on the 28th of next month at 5 AM")
return


; Arl => /remind list
:*:Arl::
	Send _r{left}{backspace}/{right}{right}emind list
	Sleep 200
	Send {Enter}
return


; Damn Slack and their new search shortcuts popup that can't be disabled.
:*:Ar2::
	Send _r{left}{backspace}/{right}{right}emind me to{space}
return

; Remind me to do something at 5 AM tomorrow.
:*:Ar5::
	Send _r{left}{backspace}/{right}{right}emind me to{space}{space}tomorrow at 5 AM{left 17}
return

:*:Ar$::
	Send _r{left}{backspace}/{right}{right}emind me to budget{space}
	Send ^v
	Send {space}for  tomorrow at 5 AM{left 17}
return


; Remind me to do something at 5 AM tomorrow.
; Uses left key to put the cursor back at the right spot.
; :*:Ar5t::
;	Send _r{left}{backspace}/{right}{right}emind me to  at 5 AM tomorrow{left 17}
; return



; <C click> => /remind list
^LButton::
	Send _r{left}{backspace}/{right}{right}emind list
	Sleep 200
	Send {Enter}
return

$a::
	handleSlackReminderHotkey("a", 0, "completeSlackReminder")
return


; Pressing o when hovering over a reminder snoozes it for 1 hour.
$o::
	handleSlackReminderHotkey("o", 2, "deferSlackReminder")
return


; Pressing e when hovering over a reminder snoozes it for 3 hours.
; Using e so that left hand can type all the action keystrokes while right hand moves mouse.
; In Programmer Dvorak, aoeu are home position keys for right hand.
$e::
	handleSlackReminderHotkey("e", 3, "deferSlackReminder")
return


; Pressing u when hovering over a reminder snoozes it until tomorrow.
; Using u so that left hand can type all the action keystrokes while right hand moves mouse.
; In Programmer Dvorak, aoeu are home position keys for right hand.
$u::
	handleSlackReminderHotkey("u", 4, "deferSlackReminder")
return


#IfWinActive


;===============================================================================
; Numberpad

; The bluetooth numberpad I got don't work right in Programmer Dvorak.
; Need to remap some of the keys.

; 62  048	 	d	5.56	Numpad2 
; 63  049	 	d	2.03	Numpad3        	
; 64  04B	 	d	0.23	Numpad4        	
; 65  04C	 	d	3.72	Numpad5
; 66  04D	 	d	5.05	Numpad6        	
; 69  051	 	d	0.94	Numpad9        	

SC048::
	Send {up}
return

SC049::
	Send {PgUp}
return

SC04D::
	Send {right}
return

SC04B::
	Send {left}
return

SC04C::
	Send {space}
return

SC051::
	Send {PgDn}
return


;===============================================================================
; Submode Launching


;-------------------------------------------------------------------------------
; <W u> => UVU mode.
$#u::
	; SoundPlay %A_ScriptDir%\Sounds\UVU_Start.wav
	Run %A_ScriptDir%\UVU.ahk
return

;-------------------------------------------------------------------------------
; <Window + n> => Navigation mode.
$#n::
    SoundPlay %A_ScriptDir%\Sounds\Navigation_Start.wav

    ; NOTE: The Windows file assosciation for Open on .ahk files must be set to AutoHotKey.exe.
    Run %A_ScriptDir%\Navigation.ahk
return

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
    ; Example #2: This will visit all windows on the entire system and display info about each of them:
    WinGet, id, list,,, Program Manager
    Loop, %id% {
        this_id := id%A_Index%
        WinActivate, ahk_id %this_id%
        WinGetClass, this_class, ahk_id %this_id%
        WinGetTitle, this_title, ahk_id %this_id%
        MsgBox, 4, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
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

    Sleep 150
    ; WinMaximize, swdev, Pidgin
    ; WinMaximize, (swdev), Pidgin

    ; Mainly on my desktop at digEcor should this happen.
    if (host != "XPS15") {
        x := 380
        y := 280

        ; This is a hack until I put in code which detects which monitor each window is in.
        ; WinMaximize, Ubuntu 13 64-bit - VMware Player
        ; WinMaximize, XChat

        ; For Outlook 2013.
        ; WinMaximize, Inbox
        ; WinMaximize, Calendar - Jeffrey.Anderson@uvu.edu - Outlook

    }
return


;-------------------------------------------------------------------------------
; Remapping for the Logitech LX8 Cordless Laser mouse on my Windows 7 workstation at digEcor.
; Also remapped on my Razer Naga Hex on Windows 8 using the Razer Synapse software.

; The back button on the mouse is mapped to <Ctrl + Shift + M>.
; You can't assign <Window + M> directly, so I will remap.

; In this case, we *do* want hotkey retriggering by Send because I have <Window + M> remapped
; not to minimize development chat in P!
; Unfortunately, it isn't retriggering for some other reason.  So, must factor out into a function.
; Or just copy and paste.

; <mouse back button> => <Ctrl + Shift + M> => <Window + M>
$^+m::
    Send #m
    Sleep 150
    ; WinMaximize, swdev, Pidgin
    ; WinMaximize, (swdev), Pidgin

    ; This is a hack until I put in code which detects which monitor each window is in.
    ; Need to disable these in Brisbane since only have 1 monitor here.
    WinMaximize, Ubuntu 13 64-bit - VMware Player
    WinMaximize, XChat
    ; For Outlook 2013.
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

    ; Gui, Add, Button, gButton_HomeContexts w250 default, &Home Contexts
    ; Gui, Add, Button, gButton_WorkContexts w250, &Work Contexts
	; Gui, Add, Button, gButton_Agendas w250, &Agendas
	; Gui, Add, Button, gButton_Recurring w250, &Recurring

	; WARNING; The checkbox does not sync with the value of its out var on creation!
	; Also, it seems like you need to put "checked" first in the options arg.
	isChecked := (OPT_LEFT_SCROLL) ? "checked" : ""
	
	; Mark this GUI as being the "last found" window.
	Gui, +LastFound	
	Gui, Add, Checkbox, %isChecked% vOPT_LEFT_SCROLL gOPT_LEFT_SCROLL, Enable &scrolling with left control and shift?
	isChecked := (OPT_SPEAK) ? "checked" : ""
	Gui, Add, Checkbox, %isChecked% vOPT_SPEAK gOPT_SPEAK, Spea&k when hotkeys and hotstrings are triggered?
	Gui, Add, Button, gButton_Budget w250, &Budget
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
; TO DO: Verify works on XPS15.

; Open all @ files in home contexts in a single gVim.
Button_HomeContexts:
	Gui, Destroy
	Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Home
	Sleep 1000
	Send #{Up}
	Sleep 100
	MouseMove 1450, 430
	Click
	Sleep 100
	Send {PgUp}
	Sleep 50
	Send {PgUp}
	Sleep 50
	Send ^a
	Sleep 500
	Send +{F10}
	Sleep 200

	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50

	Send {Enter}
	WinWait 500
	WinActivate GVIM

return


; Open all @ files in work contexts in a single gVim.
Button_WorkContexts:
	Gui, Destroy
	Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Work
	Sleep 1000
	Send #{Up}
	Sleep 100
	MouseMove 1450, 430
	Click
	Sleep 100
	Send {PgUp}
	Sleep 50
	Send {PgUp}
	Sleep 50
	Send ^a
	Sleep 500
	Send +{F10}
	Sleep 200

	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50

	Send {Enter}
	WinWait 500
	WinActivate GVIM

return


; Open all @ files in agendas in a single gVim.
Button_Agendas:
	Gui, Destroy
	Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Agendas
	Sleep 1000
	Send #{Up}
	Sleep 100
	MouseMove 1450, 430
	Click
	Sleep 100
	Send {PgUp}
	Sleep 50
	Send {PgUp}
	Sleep 50
	Send ^a
	Sleep 500
	Send +{F10}
	Sleep 200

	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50

	Send {Enter}
	WinWait 500
	WinActivate GVIM

return


; Open all recurring tasks files in a single gVim.
Button_Recurring:
	Gui, Destroy
	Run C:\Users\jadeaxon\Dropbox\Organization\To Do\Recurring
	Sleep 1000
	Send #{Up}
	Sleep 100
	MouseMove 1450, 430
	Click
	Sleep 100
	Send {PgUp}
	Sleep 50
	Send {PgUp}
	Sleep 50
	Send ^a
	Sleep 500
	Send +{F10}
	Sleep 200

	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50
	; The context menu pops up different in this folder, so need to go down 2 more.
	Send {Down}
	Sleep 50
	Send {Down}
	Sleep 50

	Send {Enter}
	WinWait 500
	WinActivate GVIM

return


; Updates current budget file.
; PRE: You've copied the expense amount to the clipboard.
; PRE: gVim is the default app for .txt files.
; PRE: NEXT is on a line by itself in the budget file where the next entry should go.
Button_Budget:
	Gui, Destroy
	
	remainingBudget := ""
	amount := 0

	amount := Clipboard
	StringReplace amount, amount, $,
	StringReplace amount, amount, `,, ; In case we're over $1,000.	
	amount := abs(amount)

	if (amount <= 0) {
		MsgBox,, Error, You did not copy an amount to the clipboard.
		return
	}

	Clipboard := ""

	; Open budget file in gVim.
    EnvGet, home, USERPROFILE
	Run, %home%\Dropbox\Organization\Financial\Budget\%A_YYYY% Budget.txt
	Sleep 500
	WinActivate ahk_exe gvim.exe
	WinWaitActive ahk_exe gvim.exe

	; Vim commands.
	SendInput, {esc}{esc}
	SendInput, gg
	SendInput, /NEXT{enter}
	SendInput, {up}
	SendInput, "{+}yW

	; Get remaining budget amount from the clipboard.
	ClipWait 0
	remainingBudget := Clipboard

	; Remove leading $.
	StringReplace remainingBudget, remainingBudget, $,
	StringReplace remainingBudget, remainingBudget,  `,, ; In case we're over $1,000.	
	; MsgBox % remainingBudget

	remainingBudget := abs(remainingBudget)

	; Get the new remaining budget rounded to two decimal points.
	newRemainingBudget := remainingBudget - amount
	newRemainingBudget := round(newRemainingBudget, 2)

	; MsgBox,,, orb: %remainingBudget%`namt: %amount%`nnrb: %newRemainingBudget%
	
	out := "$" . newRemainingBudget
	out := RegExReplace(out, "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,") ; Commify number.

	SendInput, o
	SendInput, %out%{space}
	; You should now type in the purchase description.

return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + d> => Popup common tasks at digEcor.
; I've disabled this so <C-A d> can be used for day mode (since no longer work at digEcor).

; $^!d::
Disabled:
    Gui, Add, Button, gButton_ClockIn w150 default, Clock &In

Gui, Add, Button, gButton_ClockOut w150, Clock &Out
    Gui, Add, Button, gButton_TimeCard w150, &Time Card
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
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, WM Clock
    WinWaitActive, WM Clock

	password := property("aplus.timeclock.password")
    Send {Tab}
	Send janderson{Tab}
    Send %password%{Tab}
	Send {Enter}

    ; In case another one pops back up.
	Sleep 7000
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F4}
    }

	x := 600
	y := 552
	EnvGet, host, COMPUTERNAME
	if (host = "JANDERSON-DT") {
		x := 886
		y := 616
	}

	MouseMove x, y
	Sleep 1000
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
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, WM Clock
    WinWaitActive, WM Clock

	password := property("aplus.timeclock.password")
    Send {Tab}
	Send janderson{Tab}
    Send %password%{Tab}
	Send {Enter}

    ; In case another one pops back up.
	Sleep 7000
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F4}
    }

	x := 770
	y := 552
	EnvGet, host, COMPUTERNAME
	if (host = "JANDERSON-DT") {
		x := 1045
		y := 611
	}
	MouseMove x, y
	Sleep 1000
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

    Sleep 1000
	password := property("aplus.timeclock.password")
    Send {Tab}janderson{Tab}
    Send %password%{Enter}

	Sleep 1000
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
    ;~ Sleep 1000
    ;~ Send {Backspace}

;~ return

;~ ; This fails too.
;~ $#Space::
    ;~ Send {Space}
    ;~ Sleep 1000
    ;~ Send {Backspace}

;~ return

; This works but is somewhat timing sensitive to how long it takes you to release the shift key and how long it takes ShortKeys to expand abbreviation.
; Well, this was an interesting idea, but it turn out to be annoying in practical use.
; $+Space::
;     Sleep 300 ; Give time for me to release the <Shift + Space> so <Shift> isn't held down while ShortKeys expands abbreviation.
;     Send {Space}
;     Sleep 300 ; Give time for ShortKeys to expand abbreviation.
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
    Sleep 1000
    WinActivate, Untitled - Paint
    WinWaitActive, Untitled - Paint
    Send ^v
return


;===============================================================================
; ABBREVIATION HOTSTRINGS


; Prints out date with bar above and below it.
; FAIL.
dateBars(barChar) {
    FormatTime, monthDay,, d
    FormatTime, month,, MMMM
    FormatTime, weekDay,, dddd
    FormatTime, year,, yyyy

    monthDay := ordinal(monthDay)

    minus := "-"
    equals := "="
    longBar := "uninitialized"
    if barChar = %minus%
    {
        longBar := "-------------------------------------------------------------------------------------------------------------------------"
    }
    if barChar = %equals%
    {
        longBar := "========================================================================================================================="
    }


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
} ; dateBars(barChar)


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


; <ymd> => 2012/07/27
::<ymd>::
    FormatTime, year,, yyyy
    FormatTime, month,, MM
    FormatTime, day,, dd

    output = %year%/%month%/%day%
    SendInput %output%
return


; <ymd-> => 2012-07-27
::<ymd->::
    FormatTime, year,, yyyy
    FormatTime, month,, MM
    FormatTime, day,, dd

    output = %year%-%month%-%day%
    SendInput %output%
return


; Expand to the kind of date heading I use in my journal.
; ::<date--bars>::
;    dateBars(-)
; return


::<date-->::
    ; dateBars(-)
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
    ; dateBars(-)
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
	bar80 := "==============================================================================="
	FormatTime, dateString,, yyyy-MM-dd

    SendInput %bar80%
    SendInput {Enter}
    SendInput %dateString%
    SendInput {Enter}
    SendInput %bar80%
    SendInput {Enter}
    SendInput {Enter}

return



;==============================================================================
; Toad
;==============================================================================

; Adds some extra password-enterting power to the Toad F5 shortcut key.
; This deals with the table setup scripts that need the password twice.
#IfWinActive fzjebt_setup.sql ahk_class TfrmMain ahk_exe Toad.exe
$F5::
    EnvGet, home, USERPROFILE
	
	; Goddamn DBAs can't set the paswords consistently.
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All
	
	FileRead, password, %home%\.ssh\toad_password.txt
	password := Trim(password)
	StringReplace, password, password, `n, , All
	
	Send {F5}
	; This will time out in 3 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,3
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}
	SendRaw %old_password%
	Send {enter}
	Sleep 1000	
	
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe
	; Goddamn password has a # in it!
	SendRaw %password%
	Send {enter}

return
#IfWinActive


#IfWinActive codesep_table_setup.sql ahk_class TfrmMain ahk_exe Toad.exe
$F5::
    EnvGet, home, USERPROFILE
	
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All
	
	Send {F5}
	; This will time out in 3 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,3
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
$F5::
    EnvGet, home, USERPROFILE
	
	FileRead, old_password, %home%\.ssh\old_toad_password.txt
	old_password := Trim(old_password)
	StringReplace, old_password, old_password, `n, , All

	FileRead, password, %home%\.ssh\toad_password.txt
	password := Trim(password)
	StringReplace, password, password, `n, , All

	Send {F5}
	; This will time out in 3 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,3
	if ErrorLevel
	{
		;; MsgBox,, Timed out.
		return
	}

	SendRaw %old_password%
	Send {enter}
	
	Sleep 4000
	
	; This will time out in 3 seconds in which case ErrorLevel gets set to 1.
	WinWaitActive, ahk_class TToadLogOnForm ahk_exe Toad.exe,,3
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
	if (FileExist("C:\Program Files\AutoHotkey\AU3_Spy.exe")) {
		Run, C:\Program Files\AutoHotkey\AU3_Spy.exe
	}
	else if(FileExist("C:\Program Files\AutoHotkey\WindowSpy.ahk")) {
		Run, C:\Program Files\AutoHotkey\WindowSpy.ahk
	}
return

; <C w> => close AHK Window Spy
#IfWinActive ahk_exe AU3_Spy.exe
$^w::
	Send !{F4}
return
#IfWinActive

#IfWinActive Window Spy
$^w::
	Send !{F4}
return
#IfWinActive

; Make the Windows 10 settings window close via <C w>.
#IfWinActive Settings ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe
$^w::
	Send !{F4}
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

    ; *64 is one of the system sounds.
    SoundPlay *64
	speak("Reloading Modes")
    Reload

    ; This code can only be reached if reloading fails.
    Sleep 1000
    MsgBox 4, , Script reloaded unsuccessful, open it for editing?
    IfMsgBox Yes, Edit
return



;==============================================================================
; Functions

; Speaks given message using computer-generated voice.
speak(message) {
	Global OPT_SPEAK	
	if (OPT_SPEAK) {
		ComObjCreate("SAPI.SpVoice").Speak(message)	
	}
}


; Emits a Slack reminder request.
remind(what) {
	; The prefix keeps Slack's annoying new shortcuts "helper" from popping up.
	prefix := "_r{left}{backspace}/{right}{right}emind me to"
	Send %prefix% %what%
	Sleep 200
	Send {enter}
}


