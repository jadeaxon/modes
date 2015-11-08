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


; Load this timer after the icon or else the icon won't load.
; Poll the status of Vim every ??? ms to see if we should enable/disable ShortKeys.
; 100 ms seems fast enough.  Very responsive.  Doesn't appear to burden CPU at all.
; 200 ms feels a tad bit too slow.
;
; PRE: RAM disk R:\ must exist and be writable.
; PRE: For this to work, ShortKeys.vim must have been sourced in Vim.  This enables autocommands which update the vim_status.txt file.  
; SetTimer, CheckVimStatus, 100

; SetTimer, ReadMessageQueue, 1000


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
			bedtimeDisplayProfile()
			zeroBrightness()
		}
		else { ; Between 5 AM and 9 PM.
			; MsgBox,,, Normal	
			normalDisplayProfile()
		}
	}
	else { ; Later than 9 PM
		bedtimeDisplayProfile()
		zeroBrightness()
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
; Hotkeys
;=============================================================================== 

; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.  


; Make is so that <Window + Space> does not switch input languages.  This is causing me to nearly die
; in Path of Exile.
#space::return


$^!l::
    ; Send ^!{Delete}
    ; Send ^!{vk2Esc153} ; This lets you lock the screen.
    Run taskmgr
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
; <A-a> => archive.  Can't use this.  Roboform pops up some damn add new passcard dialog each time.
; <C-a> => archive.
; Also note that in Hotmail, <C-.> moves to next message and <C-,> moves to previous message.
; So, using these three shortcuts is great for processing your @Waiting folder during a weekly review.
; PRE: <C-0> to return Firefox to default zoom level.
; PRE: Firefox.  Hotmail.  Dell XPS 15.  1366x768.
#IfWinActive Outlook ahk_class MozillaWindowClass
$^a::
    ; Zoom back to default and scroll to top of page.
    Send ^0
    Send {Home}
    ; Open 'Move to Folder' menu.
    ; The new Outlook.com UI has a dedicated archive button (like Google) now.
    ; MouseMove 600, 170
    ; MouseClick
    ; Select 'Archive' folder.
    
    ; Clickj the new Archive button.
    Sleep 100
    ; MouseMove 435, 115
    MouseMove 470, 130
    MouseClick
    Sleep 100
    ; Click so that arrow keys will scroll the new current message.
    MouseMove 480, 155
    MouseClick
    MouseClick
    
return
#IfWinActive  


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
#ifWinActive Inbox - jeff.anderson@digecor.com - Outlook ahk_class rctrl_renwnd32
$^a::
    Send ^+1    
return
#IfWinActive

#IfWinActive @Waiting - jeff.anderson@digecor.com - Outlook ahk_class rctrl_renwnd32
$^a::
    Send ^+1
return
#IfWinActive

#ifWinActive @Test - jeff.anderson@digecor.com - Outlook ahk_class rctrl_renwnd32
$^a::
    Send ^+1    
return
#IfWinActive

#ifWinActive @Release Plan - jeff.anderson@digecor.com - Outlook ahk_class rctrl_renwnd32
$^a::
    Send ^+1    
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

    

;-------------------------------------------------------------------------------
; <C-w> in Sumatra PDF Reader closes the app.
#IfWinActive ahk_class SUMATRA_PDF_FRAME
$^w::
    WinClose, A
#IfWinActive




; Vaio Laptop and Dell XPS 410.
; A0  02A	 	d	0.03	Left Shift     	
; 2D  152	 	d	0.02	Insert         	
; 2D  152	 	u	0.09	Insert         	
; A0  02A	 	u	0.14	Left Shift     
$^k::
    ; TO DO: This does not work on my Windows 7 64-bit workstation.
    WinGetClass, class, A
    if (class = "mintty") {
        ; Apparently, {Insert} does not map to the insert key on my Vaio laptop.
        ; Send {vkA0sc02A Down}{vk2Dsc152}{vkA0sc02A Up}
        Send +{vk2Dsc152}
    }
    else { ; Not mintty.
        Send ^v
    }
    
    
return    
    


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



;~ ;-------------------------------------------------------------------------------
;~ ; <Ctrl + Tab> => activate next PuTTY window.

;~ #IfWinActive ahk_class PuTTY
;~ LCtrl & Tab::
    ;~ ; Send {Right Ctrl Down}{Tab}{Right Ctrl Up}
    ;~ Send {vkA3sc11D Down}
    ;~ Send {vk09sc00F}
    ;~ Send {vkA3sc11D Up}
    
    ;~ ; A3  11D	 	d	14.98	RControl       	
    ;~ ; 09  00F	 	d	0.25	Tab            	
    ;~ ; 09  00F	 	u	0.11	Tab            	jdev (172.16.40.108) - PuTTY
    ;~ ; A3  11D	 	u	0.19	RControl  
    
;~ return 

;~ #IfWinActive



;-------------------------------------------------------------------------------
; <Ctrl + V> => <Shift + Insert> => paste from clipboard in mintty (Cygwin).
; Make <Ctrl + V> paste into Cygwin/mintty windows.
; Usually <Ctrl + V> lets you insert literal characters (like control characters).
; You'll have to disable Master.ahk to get that back in the rare cases that you need it.
; TO DO: You might only want this when typing commands into Bash.
#IfWinActive ahk_class mintty
$^v::
    ; Apparently, {Insert} does not map to the insert key on my Vaio laptop.
    ; Send {vkA0sc02A Down}{vk2Dsc152}{vkA0sc02A Up}
    ; Send +{Insert}
    Send +{vk2Dsc152}
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
#IfWinActive


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
#IfWinActive


;===============================================================================
; SUBMODE LAUNCHING


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
        ; WinMaximize, Calendar - jeff.anderson@digecor.com - Outlook

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
    WinMaximize, Calendar - jeff.anderson@digecor.com - Outlook
    
return


;-------------------------------------------------------------------------------
; <Ctrl + Alt + M> => <Window + M>
; Doing this for Razer Synapse since I can't enter <Window + M> into their edit screen.
$^!m::    
    Send #m
return    


;-------------------------------------------------------------------------------
; <Ctrl + Alt + J> => Popup GUI for common personal tasks.  J == Jeff.  

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
; <Ctrl + Alt + D> => Popup common tasks at digEcor.

$^!d::
    Gui, Add, Button, gButton_ClockIn w150 default, Clock &In  

Gui, Add, Button, gButton_ClockOut w150, Clock &Out    
    Gui, Add, Button, gButton_TimeCard w150, &Time Card
    Gui, Add, Button, gButton_PreviousTimeCard w150, &Previous Time Card
    Gui, Show,, digEcor
    
return  

; TO DO: Modify these to wait for symbols.

; TO DO: When A Plus' site is down, you can still access the timeclock here: https://www.swipeclock.com/sc/clock/webclock.asp

; Clocks into digEcor (APlus) time clock.
Button_ClockIn:
    Gui, Destroy
    Run https://www.swipeclock.com/sc/clock/webclock.asp
    WinWait, Web Clock
    WinActivate, Web Clock
    
    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, Web Clock
    WinWaitActive, Web Clock
    
	password := property("aplus.timeclock.password")
    Send janderson{Tab}
    Send %password%{Tab}
    Send {Space}
    Sleep 50
    Send {Tab}
    Sleep 50
    Send {Enter}
    
    ; In case another one pops back up.
	sleep 1000 
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F4}
    }
    
return


; Clock out of digEcor (APlus) time clock.
Button_ClockOut:
    Gui, Destroy
    Run https://www.swipeclock.com/sc/clock/webclock.asp
    
    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, Web Clock
    WinWaitActive, Web Clock
    
	password := property("aplus.timeclock.password")
    Send janderson{Tab}
    Send %password%{Tab}
    Sleep 50
    Send {Space}
    Sleep 200
    Send {vk27sc14D} ; Send {Right}
    Sleep 100
    Send {Tab}
    Sleep 100
    Send {Enter}
   
    ; In case another one pops back up.
	sleep 1000 
    IfWinActive, AutoFill - RoboForm
    {
        Send !{F4}
    }
    
	
return


; Show the digEcor (APlus) time card for the current week.
Button_TimeCard:
    Gui, Destroy
    Run https://www.swipeclock.com/sc/clock/timecard.asp
    WinWait, Web Clock - Mozilla Firefox
    WinActivate, Web Clock - Mozilla Firefox
    
    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, Web Clock
    WinWaitActive, Web Clock
    
	
    Sleep 1000
	password := property("aplus.timeclock.password")
    Send janderson{Tab}
    Send %password%{Enter}
    
    ; In case another one pops back up.
    WinClose, AutoFill - RoboForm
    
return


; Show the digEcor (APlus) time card for the previous week.
Button_PreviousTimeCard:
    Gui, Destroy
    Run https://www.swipeclock.com/sc/clock/timecard.asp
    WinWait, Web Clock - Mozilla Firefox
    WinActivate, Web Clock - Mozilla Firefox
    
    ; Close RoboForm.
    WinWait, AutoFill - RoboForm
    WinActivate, AutoFill - RoboForm
    WinWaitActive, AutoFill - RoboForm
    Send !{F4}
    Sleep 250
    ; Reactivate because RoboForm steals focus.
    WinActivate, Web Clock
    WinWaitActive, Web Clock
    
	password := property("aplus.timeclock.password")
	Send janderson{Tab}
    Send %password%{Tab}
    Sleep 200
    Send {vk27sc14D} ; Send {Right}
    Sleep 50
    Send {Tab}
    Sleep 50
    Send {Enter}
    
    ; In case another one pops back up.
    WinClose, AutoFill - RoboForm
    
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




; 9:30 AM
::<time>::
    FormatTime, output,, h:mm tt
    SendInput %output%
return


; 8/11/2011 9:30 AM
::<ts>::
    FormatTime, output,, M/d/yyyy h:mm tt
    SendInput %output%
return

; 02/22/2O12
::<mdy>::
    FormatTime, output,, MM/dd/yyyy
    SendInput %output%
return



;==============================================================================
; Bookmark Transitions

; <A n> => open next bookmark
#IfWinActive Slashdot ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send https://news.ycombinator.com/
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Hacker News ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send https://www.reddit.com/
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive reddit: ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send http://lifehacker.com/
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Lifehacker ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send http://dilbert.com/
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActiveach Dilbert ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send http://www.merriam-webster.com/word-of-the-day/
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Word of the Day ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send http://www.quotationspage.com/random.php3
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Random Quotes ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send https://www.facebook.com/naturepicturesoftheday
   Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Nature Pictures ahk_class MozillaWindowClass
$!n::
	Send ^l
	Send https://www.hotmail.com
	Send {Enter}
	; This assumes Roboform autofill pops up and mouse automoves to default dialog button.
	Sleep 1000
	WinActivate AutoFill - RoboForm ahk_class #32770
	Sleep 100
	Send {Enter}
return
#IfWinActive  


;-------------------------------------------------------------------------------
; <Ctrl + ESC> => Reload this script.
;
; Reload this AutoHotKey script.
; This is like sending a restart signal to a veb server so it can reload its configuration file.
LControl & Escape::
    ; *64 is one of the system sounds.
    SoundPlay *64
    Reload
    ; This code can only be reached if reloading fails.
    Sleep 1000
    MsgBox 4, , Script reloaded unsuccessful, open it for editing?
    IfMsgBox Yes, Edit
return



