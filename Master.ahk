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

; Persistent scripts keep running forever until explicitly closed.
#Persistent

; Allow match anywhere within title.
SetTitleMatchMode, 2

; NOTE: You must *not* put any hotkey definitions before here or this won't execute.

; Give the computer five minutes to boot up all its startup crap.
; On newer machines, this is no longer necessary.
;~ Suspend On
;~ secondsSinceBoot := A_TickCount / 1000
;~ while (secondsSinceBoot < 300) {
    ;~ Sleep 1000
    ;~ secondsSinceBoot := A_TickCount / 1000
;~ }
;~ Suspend Off


; This shell window receives events whenever other main windows are created, activated, resized, or destroyed.
Gui +LastFound
hWnd := WinExist()

; Well, autotoggling ShortKeys is a nice idea, but the tray icon detection and activation doesn't always work and
; it's not smart enough to let you toggle it back from what itss thinks it should be for a given window.  So, it ends
; up being more annoying than useful as currently implemented.
autoToggleShortKeys = false
if (hWnd and autoToggleShortKeys) {
	; MsgBox,,, Found shell window

	DllCall("RegisterShellHookWindow", UInt, hWnd)
	MsgNum := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")
	OnMessage(MsgNum, "ShellMessage")

} ; if


;-------------------------------------------------------------------------------
; A loop that periodically checks my graphics scheme.
; If it is between 8 PM and 5 AM, then put it in night mode if not already.  Vice versa the rest of the day.
; Instead of trying to figure out state, assume.
; At transition to night, assume you haven't flipped and do it once.
; So, just poll the time every minute.  Save last polled time.
; Is day time?  Is night time?  00 01 10 11.
; If transition, change scheme.

; Menu, Tray, Icon, C:\Users\Jade Axon\Desktop\AHK\Icons\Master.ico
Menu, Tray, Icon, %A_ScriptDir%\Icons\Master.ico

CoordMode, Mouse, Relative

; Periodically runs the code at the given label.
now := A_Hour
;dayMode := not isDayTime(now) ; Force
dayMode := false
;SetTimer, CheckGraphicsScheme, 60000 ; 60 seconds

;CheckGraphicsScheme:


;    _checkGraphicsScheme()
;return

; Group all Explorer windows.  Used by a shortcut to close them all.
GroupAdd,ExplorerGroup, ahk_class CabinetWClass
GroupAdd,ExplorerGroup, ahk_class ExploreWClass


; Load this timer after the icon or else the icon won't load.
; Poll the status of Vim every ??? ms to see if we should enable/disable ShortKeys.
; 100 ms seems fast enough.  Very responsive.  Doesn't appear to burden CPU at all.
; 200 ms feels a tad bit too slow.
;
; PRE: RAM disk R:\ must exist and be writable.
; PRE: For this to work, ShortKeys.vim must have been sourced in Vim.  This enables autocommands which update the vim_status.txt file.
; SetTimer, CheckVimStatus, 100

; SetTimer, ReadMessageQueue, 1000

Run %A_ScriptDir%\AutoCorrect.ahk

; Start ShortKeys disabled.
; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being enabled/disabled.
; This relies on Master.ahk starting up *after* ShortKeys at boot.
Sleep 5000
Send ^!s




; On my ShortKeys installation at work, the option to not show editor on startup is grayed out for unknown reasons.
; So, I hack it with this.
IfWinExist, ShortKeys
{
    WinActivate, ShortKeys
    Send !f
    Sleep 50
    Send h
}

; Close the error window from 7+ Taskbar Tweaker.
WinClose, Error
; ahk_class #32770



EnvGet, host, COMPUTERNAME
if (host = "XPS15") {
	; Switch to normal display profile if started between 5 AM and 8 PM.
	hour := A_Hour + 0 ; Convert to int.  A_Hour seems to be zero-padded string.
	if (hour < 21) {
		if (hour < 4) {
			; bedtimeDisplayProfile()
			; zeroBrightness()
		}
		else { ; Between 5 AM and 9 PM.
			; MsgBox,,, Normal
			; normalDisplayProfile()
		}
	}
	else { ; Later than 9 PM
		; bedtimeDisplayProfile()
		; zeroBrightness()
	}
}


; Send a keystroke every five minutes to keep Tod's stupid admin settings from automatically locking the machine.
Loop {
    Sleep 1000 * 60 * 5
    Send {Shift Down}
    Send {Shift Up}
}

return



;===============================================================================
; TIMER GOSUB LABELS
;===============================================================================


previousModTime := 0
CheckVimStatus:
    ; TODO: Check to see if the status file even exists.

    ; Need to see if R:\vim_status.txt has been modified.
    ; If so, and 'insert mode', and ShortKeysIsDisabled() => enable ShortKeys via <Ctrl + Alt + S>
    ; If so, and 'normal mode', and ShortKeysIsEnabled() => disable ShortKeys via <Ctrl + Alt + S>
    statusFile := "R:\vim_status.txt"
    currentModTime := 0

    ; Get the file's modification time.
    FileGetTime, currentModTime, %statusFile%, M

    ; See EnvSub function.  AHK is psychotic.
    timeDiff := currentModTime
    timeDiff -= previousModTime, Seconds

    ; MsgBox,,, Mod times and delta: %currentModTime% %previousModTime% %timeDiff%, 1

    ; NOTE: Since modification times are in seconds, toggling ShortKeys will fail if a mode switch is made within the same second.
    ; Usually, this will not happen.
    if (timeDiff > 0) {
        FileRead, vim_status, %statusFile%
        if not ErrorLevel  {  ; Successfully loaded.
            ; See AutoTrim.
            vim_status = %vim_status% ; This trims leading and trailing whitespace.  But not newlines, I guess.
            StringReplace, vim_status, vim_status, `n, , All

            ; MsgBox,,, "%vim_status%"

            ; PRE: ShortKeys is running.
            if (vim_status == "insert mode") {
                if ( not ShortKeysIsEnabled() ) {
                    ; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being enabled/disabled.
                    Send ^!s
                }
            }
            else if (vim_status == "normal mode") {
                if ( ShortKeysIsEnabled() ) {
                    ; <Ctrl + Alt + s> - this is set inside ShortKeys to toggle being enabled/disabled.
                    Send ^!s
                }
            }
            else { ; Unknown status.
                ; Do nothing.
            } ; else

            vim_status =  ; Free the memory.
        } ; if not ErrorLevel

        ; MsgBox,,, Vim status changed: %currentModTime% %previousModTime% %timeDiff%
    }
    else { ; The file has not changed.
        ; Do nothing.
    }

    previousModTime := currentModTime

return ; from CheckVimStatus:





ReadMessageQueue:
    ProcessNextMessage()

return





;===============================================================================
; Functions
;===============================================================================

#Include %A_ScriptDir%\Library.ahk
#Include %A_ScriptDir%\Message Server.ahk
#Include %A_ScriptDir%\Kindle.ahk

; This gets called whenever a window event occurs such as creation, activation, etc.
;~ The documented values for wParam are:
    ;~ HSHELL_WINDOWCREATED = 1
    ;~ HSHELL_WINDOWDESTROYED = 2
    ;~ HSHELL_ACTIVATESHELLWINDOW = 3
    ;~ HSHELL_WINDOWACTIVATED = 4
    ;~ HSHELL_GETMINRECT = 5
    ;~ HSHELL_REDRAW = 6
    ;~ HSHELL_TASKMAN = 7
    ;~ HSHELL_LANGUAGE = 8
    ;~ HSHELL_SYSMENU = 9
    ;~ HSHELL_ENDTASK = 10
    ;~ HSHELL_ACCESSIBILITYSTATE = 11
    ;~ HSHELL_APPCOMMAND = 12
    ;~ HSHELL_WINDOWREPLACED = 13
    ;~ HSHELL_WINDOWREPLACING = 14
    ;~ HSHELL_HIGHBIT = 15
    ;~ HSHELL_FLASH = 16
    ;~ HSHELL_RUDEAPPACTIVATED = 17
ShellMessage(wParam, lParam) {
    ; Disabled.
    return

	HSHELL_WINDOWACTIVATED = 4

	; Execute a command based on wParam and lParam
	; MsgBox,,, wParam = %wParam%`nlParam = %lParam%

	if (wparam = HSHELL_WINDOWACTIVATED) {
		hWnd := lParam
		WinGetTitle, title, ahk_id %hWnd%
		WinGetClass, class, ahk_id %hWnd%

		; MsgBox,,, %title% (class %class%) was activated.

		if (class = "mintty") {
			; MsgBox,,, minnty (Cygwin) was activated.
			; Need a way to check to see if ShortKeys is enabled.
			; Also, will this trigger a hotkey?  It might create an infinite loop.
			if ( ShortKeysIsRunning() ) {
				if ( ShortKeysIsEnabled() ) {
					; MsgBox,,, ShortKeys is enabled.
					; Disable ShortKeys for mintty/Cygwin.
					; This does not cause the AHK hotkey to fire.  It's guarded against retriggering.
					; Send #s ; <Window + s>
					toggleShortKeys()
				}
				else {
					; MsgBox,,, ShortKeys is suspended.
				}
			}
			else { ; ShortKeys is not running.
				; MsgBox,,, ShortKeys is not running.
			}

		}
        else { ; In all other cases, resume ShortKeys if it is suspended.
            if ( ShortKeysIsRunning() ) {
				if ( ShortKeysIsEnabled() ) {
					; MsgBox,,, ShortKeys is enabled.
                    ; Do nothing.
				}
				else { ; Suspended.
					; MsgBox,,, ShortKeys is suspended.
                    toggleShortKeys()
				}
			}
			else { ; ShortKeys is not running.
				; MsgBox,,, ShortKeys is not running.
                ; TODO: Start ShortKeys?
			}

        } ; else (class =)

	} ; if a window was activated

} ; ShellMessage(...)



_checkGraphicsScheme() {
    global ; Allows this funtion to use global variables.

    secondsSinceBoot := A_TickCount / 1000
    if (secondsSinceBoot < 300) {
        return
    }

    now := A_Hour

    ; MsgBox %A_Hour%
    nowDay := isDayTime(now)
    ; thenDay := isDayTime(then)
    ; MsgBox %thenDay% %nowDay%

    ; MsgBox, dayMode %dayMode%
    ; MsgBox, nowDay %nowDay%

    ; Transition to bedtime graphics scheme.
    if (dayMode and (not nowDay)) {
        SetKeyDelay 200

        Send, #m ; Minimize all.
        MouseMove 1250, 15 ; Top right corner of the screen--somewhere where there won't be an icon.
        Sleep 200
        Click Right
        Sleep 3000 ; Without this delay, the context menu doesn't have time to form.  You could pixel check for it, I suppose.
        Send, {vk28sc150 9} ; Down
        Send, {vk27sc14D} ; Right
        Send, {vk27sc14D} ; Right ; Just in case.
        Sleep 1000 ; Without this delay, the context submenu doesn't have time to form.
        Send, {vk0Dsc01C} ; Enter
        Send, {vk0Dsc01C} ; Just in case.

        SetKeyDelay 0

        dayMode := false

    } ; if bedtime

    ; Transition to normal (daytime) graphics scheme.
    if ((not dayMode) and nowDay) {
        SetKeyDelay 200
        Send, #m ; Minimize all.
        MouseMove 1250, 15 ; Top right corner of the screen--somewhere where there won't be an icon.
        Sleep 200
        Click Right
        Sleep 3000 ; Without this delay, the context menu doesn't have time to form.  You could pixel check for it, I suppose.
        Send, {vk28sc150 9} ; Down
        Send, {vk27sc14D} ; Right
        Send, {vk27sc14D} ; Right ; Just in case.
        Sleep 1000 ; Without this delay, the context submenu doesn't have time to form.
        Send, {vk28sc150}
        Send, {vk0Dsc01C} ; Enter
        Send, {vk0Dsc01C} ; Just in case.
        ; Send, {Enter} ;  {vk0Dsc01C}
        SetKeyDelay 0

        dayMode := true
    } ; if daytime

    return

} ; _checkGraphicsScheme()


; Is it close enough to bedtime to switch the screen to no blue spectrum?
isDayTime(hour) {

    if (false) {

    }
    else if (hour = 05) { ; 5 AM
        return true
    }
    else if (hour = 06) {
        return true
    }
    else if (hour = 07) {
        return true
    }
    else if (hour = 08) {
        return true
    }
    else if (hour = 09) {
        return true
    }
    else if (hour = 10) {
        return true
    }
    else if (hour = 11) {
        return true
    }
    else if (hour = 12) { ; noon
        return true
    }
    else if (hour = 13) {
        return true
    }
    else if (hour = 14) {
        return true
    }
    else if (hour = 15) {
        return true
    }
    else if (hour = 16) {
        return true
    }
    else if (hour = 17) {
        return true
    }
    else if (hour = 18) {
        return true
    }
    else if (hour = 19) { ; 7 PM
        return true
    }

    return false


} ; isDayTime(hour)


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
::xUSA::United States of America

; Insert a Unicode bullet symbol immediately.
; Use Windows Charater Map advanced view to search for these (or google them).
:*:uBullet::{U+2022}
:*:uDot::{U+2022}
:*:uDegrees::{U+00B0}
:*:uAry::{U+00BA} ; Ordinal indicator: primary, secondary, etc.
:*:uEuros::{U+20AC}
:*:uPlusOrMinus::{U+00B1}
:*:uInfinity::{U+221E}
:*:uIntersection::{U+2229}
:*:uUnion::{U+222A}
:*:uEnDash::{U+2013}
:*:uEmDash::{U+2014}
:*:uCheck::{U+2713}
:*:uSquared::{U+00B2}
:*:uCubed::{U+00B3}

; In Cygwin, I use j@h as a command 99% of the time.
; How would I do ~ or / in case using absolute path?
#IfWinNotActive ~
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
:*:Acddl::
	EnvGet, vUserProfile, USERPROFILE
	Run, %vUSERPROFILE%\Downloads
return

; Open a website: YouTube.
:*:Aowyt::
	Run, https://www.youtube.com
return

; Open an app: Thunderbird.
:*:Aoatb::
	Run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Mozilla Thunderbird.lnk
return


; This does not work.
; Has to be run as its own app.
; I can't figure out how to load it as part of this one.
; #Include %A_ScriptDir%\RegExHotstrings.ahk
; Probably because nothing autoexecutes after the first hotkey/hotstring is defined.


;===============================================================================
; Hotkeys
;===============================================================================

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


; Archive the message your mouse is hovered over.  In Outlook's Inbox.
; FAIL: It changes last moved-to folder to top of list, so can't use fixed position!
; WIN: Set up a "Quick Step" in Outlook with shortcut key of <C-S 1>.  You can't set <C a> as shortcut there, so you remap it here.
#ifWinActive ahk_exe OUTLOOK.EXE
$^a::
    Send ^+1
return
#IfWinActive


; Makes <C w> close Outlook.
#ifWinActive ahk_exe OUTLOOK.EXE
^w::
	Send !{F4}
return
#IfWinActive


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

; Make d act like delete key.
#IfWinActive Junk - Mozilla Thunderbird
$d::
	Send {delete}
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
	Sleep 20
	Send {alt up}
	Sleep 100
	Send mmj@
	Sleep 50
	Send {down}{down}{down}
	Sleep 50
	Send {enter}
return

; w => Move message to @Waiting.
#IfWinActive Junk - Mozilla Thunderbird
$w::
	Send {alt down}
	Sleep 20
	Send {alt up}
	Sleep 100
	Send mmj@
	Sleep 50
	Send {down}{down}{down}
	Sleep 50
	Send {enter}
	
return


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
#IfWinActive Personal Kanban ahk_class MozillaWindowClass
:*:TAh::Air out house [H1]{enter}
:*:Tt::Trash [rD1]{enter}
:*:Tbt::Big trash [rD1]{enter}
:*:Tld::Laundry (darks) [rD1]{enter}
:*:Tlw::Laundry (whites) [rD1]{enter}
:*:Tlm::Laundry (mfcs) [rD1]{enter}
:*:Tlo::Laundry (other) [rD1]{enter}
:*:Td::Dishes [rD1]{enter}
:*:Trb::Reset buffers [rD1]{enter}
:*:Tg::Guitar [rRK1]{enter}
:*:TEl::Elliptical [rH1]{enter}
:*:Ts::Shopping [rD1]{enter}
:*:Tw::Walmart [rD1]{enter}
:*:Tfm::Fresh Market [rD1]{enter}
:*:Tc::Cleaning [rDM1]{enter}
:*:T7::GTD7 [rK1]{enter}
:*:Tk::kbs 100 [rH1]^{enter}0{enter}


; Never paste formatting.  Otherwise column background colors get screwed up.
$^v::
	Send ^+v
return

$^x::
	Send ^x
	Send {backspace}
return

#IfWinActive


; Make cut and paste work right in work kanban.
#IfWinActive Work Kanban ahk_class MozillaWindowClass
$^v::
	Send ^+v
return

$^x::
	Send ^x
	Send {backspace}
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


;-------------------------------------------------------------------------------
; Make <Ctrl + T> open a new Google tab in Firefox (instead of a blank).
; Firefox is brain dead in this regard.  Why would you want to open a blank tab???
; Bloody brilliant.  This works like a charm.
;
; TIP: <Ctrl + Shift + T> resurrects the last tab you (accidentally) closed.
#IfWinActive ahk_class MozillaWindowClass
$^t::
    ; Create the new tab.
    Send ^t
    ; Go to the address bar.
    Send ^l
    ; Type in Google address.
    Send www.google.com{Enter}

return
#IfWinActive


; Adds current URL to Bookmarks Toolbar|Now bookmarks.
#IfWinActive ahk_class MozillaWindowClass
$^d::
	Send ^d
	Sleep 500
	Send {Tab}N{Enter}
return


; We're not mapping the Dvorak keys back to Qwerty when <Ctrl> is pressed.
; Though it seems like a good idea at first, it just causes much grief.
; Pass through raw to mintty.
; $^u::
;    WinGetClass, class, A
;    if (class = "mintty") {
;        Send ^u
;    }
;    else { ; Not mintty.
;        Send ^f
;    }
;
; return


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
	Send +{F10}wf
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


; <C r> => set timer to stop running on elliptcal and list all reminders.
$^r::
	Send /remind me to stop and take phone in 59m{Enter}
	Send /remind me to check recurrences at 1 PM{Enter}
	Send /remind list{Enter}
	Sleep 300
	SetNumLockState Off
	Send {PgDn}
return

; /rl => /remind list
:*:/rl::
(
/remind list

)

; /rrw => set weekly recurring reminders
; Slack has recurring reminders, but they are implemented badly.
; I want them to spawn as individual reminder instances that I can snooze
; and mark as complete.
:*:/rrw::
(
/remind me to follow R1 Daily.txt at 5 AM on Monday
/remind me to check calendar, set alarms, @<Day> -> Inbox at 5 AM on Monday
/remind me to check recurring tasks spreadsheet at 5 AM on Monday
/remind me to water plants at 5 AM on Monday
/remind me to waiting/blocked on @Waiting.txt/email/bookmarks/kanban/Jira/Planner at 5 AM on Monday
/remind me to check work email @Later at 5 AM on Monday
/remind me to check saved Teams messages at 5 AM on Monday
/remind me to check @Active Projects.txt at 5 AM on Monday
/remind me to update and sync all project boards at 5 AM on Monday
/remind me to review all work contexts and agendas at 5 AM on Monday
/remind me to read next UVU policy at 5 AM on Monday
/remind me to check https://itops.uvu.edu/secure/change_calendar/index.php at 5 AM on Monday
/remind me to follow R1 Daily.txt at 5 AM on Tuesday
/remind me to check calendar, set alarms, @<Day> -> Inbox at 5 AM on Tuesday
/remind me to check recurring tasks spreadsheet at 5 AM on Tuesday
/remind me to update ESS items on https://uvu-it.atlassian.net/projects/CA/board at 2 PM on Tuesday
/remind me to follow R1 Daily.txt at 5 AM on Wednesday
/remind me to check calendar, set alarms, @<Day> -> Inbox at 5 AM on Wednesday
/remind me to check recurring tasks spreadsheet at 5 AM on Wednesday
/remind me to conditionally IFL at 5 AM on Wednesday
/remind me to do 100 kbs at 5 AM on Wednesday
/remind me to take magnesium at 9 AM on Wednesday
/remind me to check mail at 3 PM on Wednesday
/remind me to follow R1 Daily.txt at 5 AM on Thursday
/remind me to check calendar, set alarms, @<Day> -> Inbox at 5 AM on Thursday
/remind me to check recurring tasks spreadsheet at 5 AM on Thursday
/remind me to begin GTD7 at 5 AM on Thursday
/remind me to prep for ESS meeting at 8:30 AM on Thursday
/remind me to start next week's meeting agenda at 1 PM on Thursday
/remind me to follow R1 Daily.txt at 5 AM on Friday
/remind me to check calendar, set alarms, @<Day> -> Inbox at 5 AM on Friday
/remind me to check recurring tasks spreadsheet at 5 AM on Friday
/remind me to update Banner releases master spreadsheet at 5 AM on Friday
/remind me to do hbands at 6 AM on Friday
/remind me to run water through Keurig at 2 PM on Friday
/remind me to dump @Quick Cases.txt to POB at 2 PM on Friday
/remind me to do weekly status report at 3 PM on Friday
/remind me to start next Progress (UVU).txt weekly header at 3 PM on Friday
/remind me to follow R1 Daily.txt at 5 AM on Saturday
/remind me to check recurring tasks spreadsheet at 5 AM on Saturday
/remind me to sync calendars at 5 AM on Saturday
/remind me to switch elliptical water bottle at 5 AM on Saturday
/remind me to conditionally IFL at 5 AM on Saturday
/remind me to epsom bath at 5 AM on Saturday
/remind me to clean laptop monitors at 5 AM on Saturday
/remind me to check air filters running at 5 AM on Saturday
/remind me to floss at 3 PM on Saturday
/remind me to follow R1 Daily.txt next Sunday at 5 AM
/remind me to check recurring tasks spreadsheet next Sunday at 5 AM
/remind me to respawn weekly reminders via /rrw next Sunday at 5 AM
/remind me to reset buffers next Sunday at 5 AM
/remind me to check mail next Sunday at 5 AM
/remind me to do hbands next Sunday at 5 AM
/remind me to do 100 kbs next Sunday at 5 AM
/remind me to take out big trash next Sunday at 5 AM
/remind me to peppermint garage window next Sunday at 5 AM
/remind me to update Weight.xlsx next Sunday at 5 AM
)


; /rrm => set monthly recurring reminders
; Slack has recurring reminders, but they are implemented badly.
; I want them to spawn as individual reminder instances that I can snooze
; and mark as complete.
:*:/rrm::
(
/remind me to pay Jason on the 1st of next month at 5 AM
/remind me to update POB on the 1st of next month at 5 AM
/remind me to save/invest on the 1st of next month at 5 AM
/remind me to change furnace filter on the 1st of next month at 5 AM
/remind me to change fridge baking soda on the 1st of next month at 5 AM
/remind me to change dishwasher rinse solution on the 1st of next month at 5 AM
/remind me to deep clean Norelco on the 8th of next month at 5 AM
/remind me to cycle food delivery on the 8th of next month at 5 AM
/remind me to do car checklist on the 8th of next month at 5 AM
/remind me to wash bedding on the 15th of next month at 5 AM
/remind me to empty Dyson bin, wash brush head, and swap filter on the 15th of next month at 5 AM
/remind me to touch up kitchen on the 15th of next month at 5 AM
/remind me to update POB on the 15th of next month at 5 AM
/remind me to touch up vac garage on the 22nd of next month at 5 AM
/remind me to replace peppermint on the 22nd of next month at 5 AM
/remind me to clean toilets on the 22nd of next month at 5 AM
/remind me to wash backpack on the 2nd of next month at 5 AM
/remind me to respawn monthly reminders via /rrm on the 25th of next month at 5 AM
/remind me to do monthly status report on the 28th of next month at 5 AM
)


:*:/r2::/remind me to
#IfWinActive

; SetTitleMatchMode 1


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
; <C-A n> => Put laptop into night mode.
$^!n::
	click_delay := 500
	; I had to create this control panel shortcut.
	Run "C:\Users\jadeaxon\Desktop\System\Graphics\Intel Graphics and Media.lnk"
	WinActivate, Intel(R) Graphics and Media Control Panel
	WinWaitActive, Intel(R) Graphics and Media Control Panel
	Sleep 500
	MouseMove, 315, 80 ; Display profiles dropdown.
	Click
	Sleep %click_delay%
	MouseMove, 315, 130 ; Bedtime profile.
	Click
	Sleep %click_delay%
	MouseMove, 339, 561 ; Main OK button.
	Click
	Sleep %click_delay%
	; The confirmation dialog should now be active.
	; Mouse coordinates are now relative to it.
	MouseMove, 185, 86 ; Do you really mean it dialog OK button.
	Click
	; Sleep %click_delay%

	; TO DO: Use nircmd.exe to set brightness to minimum.

return


;-------------------------------------------------------------------------------
; <C-A d> => Put laptop into day mode.
$^!d::
	; This initially worked with a 100 ms delay.  Why does my machine suddenly suck?
	click_delay := 500
	; I had to create this control panel shortcut.
	Run "C:\Users\jadeaxon\Desktop\System\Graphics\Intel Graphics and Media.lnk"
	WinActivate, Intel(R) Graphics and Media Control Panel
	WinWaitActive, Intel(R) Graphics and Media Control Panel
	Sleep 500
	MouseMove, 315, 80 ; Display profiles dropdown.
	Click
	Sleep %click_delay%
	MouseMove, 300, 150 ; Normal profile.
	Click
	Sleep %click_delay%
	MouseMove, 339, 561 ; Main OK button.
	Click
	Sleep %click_delay%
	; The confirmation dialog should now be active.
	; Mouse coordinates are now relative to it.
	MouseMove, 185, 86 ; Do you really mean it dialog OK button.
	Click
	; Sleep %click_delay%

	; TO DO: Use nircmd.exe to set brightness to minimum.

return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + j> => Popup GUI for common personal tasks.  J == Jeff.  <C-A j>.

$^!j::
    Gui, Add, Button, gButton_HomeContexts w250 default, &Home Contexts
    Gui, Add, Button, gButton_WorkContexts w250, &Work Contexts
	Gui, Add, Button, gButton_Agendas w250, &Agendas
	Gui, Add, Button, gButton_Recurring w250, &Recurring
	Gui, Show,, Personal

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




#Include %A_ScriptDir%\JRoutine.ahk


;-------------------------------------------------------------------------------
; <Ctrl + ESC> => Reload this script.
;
; Reload this AutoHotKey script.
; This is like sending a restart signal to a veb server so it can reload its configuration file.
#UseHook off
LControl & Escape::
    ; *64 is one of the system sounds.
    SoundPlay *64
    Reload
    ; This code can only be reached if reloading fails.
    Sleep 1000
    MsgBox 4, , Script reloaded unsuccessful, open it for editing?
    IfMsgBox Yes, Edit
return



