; # => Win; ^ => Ctrl;  + => Shift; ! => Alt
; $ => Don't allow "Send" output to trigger.  Don't let hotkeys trigger other hotkeys.

; The $ prefix forces the keyboard hook to be used to implement this hotkey, which as a side-effect prevents the Send command from triggering it. The $ 
; prefix is equivalent to having specified #UseHook somewhere above the definition of this hotkey.

; <Ctrl + w> => close tab in Firefox
; <Ctrl + Page Down> => next tab
; <Ctrl + Page Up> => previous tab


;=============================================================================== 
; MAIN
;===============================================================================

; NOTE: You must *not* put any hotkey definitions before here or this won't execute.

; Menu, Tray, Icon, C:\Users\Jade Axon\Desktop\AHK\Icons\Navigation.ico
Menu, Tray, Icon, %A_ScriptDir%\Icons\Navigation.ico

;=============================================================================== 
; HOTKEYS
;=============================================================================== 

; The hotkey to open Hotmail should be run in Master mode.
;^!h::
;    MsgBox This is navigation mode.
;
;return


;------------------------------------------------------------------------------- 
; Search whatever word is under the mouse with Google.
$g::
    Click
    Click
    Send, ^c
    ClipWait, 2
    if ErrorLevel {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    } ; if

    Sleep, 10
    Run http://www.google.com/search?hl=en&q=%clipboard% 
    
return

;-------------------------------------------------------------------------------
; Search whatever word is under the mouse with a dictionary.
$d::
    ;;SetTitleMatchMode 2
    Click
    Click
    Send, ^c
    Sleep, 10

    Run http://www.merriam-webster.com/dictionary/%clipboard%
return

;-------------------------------------------------------------------------------
; Look up the word under the mouse in the Wikepedia encyclopedia.
$e::
    Click
    Click
    Send, ^c
    Sleep, 10
    
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Sounds\Navigation_Wikipedia.wav
    SoundPlay %A_ScriptDir%\Sounds\Navigation_Wikipedia.wav
    Run http://en.wikipedia.org/wiki/%clipboard%
return

;-------------------------------------------------------------------------------
; Pronounce.
$p::
    Click
    Click
    Send, ^c
    Sleep, 10

    Run http://www.howjsay.com/index.php?word=%clipboard%&submit=Submit
return


;------------------------------------------------------------------------------- 
; Go back and forward in browser.
; In Dvorak, these two keys are next to each other.
;
; NOTE: Google pages intercept the backspace and screw this up.
$b::
    Send, {Backspace}
return

$m::
    Send, {Shift Down}{Backspace}{Shift Up}
return


;------------------------------------------------------------------------------- 
; spacebar => left click    
$Space::
    Click
return

;------------------------------------------------------------------------------- 
; left alt + spacebar => right click
; NOTE: Pressing ALT again dismisses the popup context menu.  This is good.
$<!Space::
    Click right
return

;-------------------------------------------------------------------------------
; Close the active window.
; Tries to always activate and maximize a next 
; If no taskbar windows, it should do nothing.  No shutdown computer dialog!
$c::
    Suspend On
    ; Avoid the "Shutdown Windows" dialog.
    WinGetActiveTitle, title
    if ( (title = "Program Manager") or (title = "Start") or (title = "") ) {
        MsgBox, , Close Window , No window is active., 1.5 ; The message box will close itself after a short while.
        SetKeyDelay 50, 50
        Send #t
        Send #+t 
        Send #+t
        Send {Enter}
        SetKeyDelay 0, 0
        Suspend Off 
        return
    }
    
    ;MsgBox, The active window was "%title%".

    SoundPlay %A_ScriptDir%\Sounds\Navigation_CloseWindow.wav
    WinClose, A
    Sleep 500
    
    ; TODO: Deal with other such confirmation dialogs.  Notepad, Eclipse, etc.
    
    ; For closing Firefox windows with multiple tabs.
    WinGetActiveTitle, title
    while (title = "Confirm close") {
        Sleep 500
        WinGetActiveTitle, title
    }
    
    
    ; There is no active window.  Let's make one active.
    if (title = "") {
        SetKeyDelay 50, 50
        Send #t
        Send #+t 
        Send #+t
        Send {Enter}
        SetKeyDelay 0, 0
    }
    
    WinGetActiveTitle, title
    
    ; One last try to activate a next window.  Look under the mouse.
    if (title = "") {
        MouseGetPos, , , title
        WinActivate, %title%
    }
    
    ; If it is minimized, then restore it.
    WinGet, mStatus, MinMax, %title%
    if (mStatus = -1 ) {
        WinRestore, %title%
    }
    
    WinMaximize, %title%
    
    Suspend Off 
return

;-------------------------------------------------------------------------------
; <Shift + c> => close all windows.

$+c::
    exclusions = Program Manager,Start,Calendar,Weather

    WinGet, id, List, , , Program Manager
    Loop, %id% {
        window := id%A_Index%
        WinGetTitle, title, ahk_id %window%
        
        if (title = "") {
            continue
        }
        
        ; You may *not* use parenthesized 'if' here.  And therefore no one true brace style!
        ; Nor do you want to put any comments or extra whitespace on the 'if' line.
        if title in %exclusions%
        { 
            ; MsgBox, Skipping %title%
            continue
        }
        ; MsgBox, Closing "%title%"
        WinClose, %title%
        
    } ; next window 
    
    
    ;~ ; Example #2: This will visit all windows on the entire system and display info about each of them:
    ;~ WinGet, id, list,,, Program Manager
    ;~ Loop, %id% {
        ;~ this_id := id%A_Index%
        ;~ ;WinActivate, ahk_id %this_id%
        ;~ WinGetClass, this_class, ahk_id %this_id%
        ;~ WinGetTitle, this_title, ahk_id %this_id%
        ;~ MsgBox, 4, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
        ;~ IfMsgBox, NO, break
    ;~ }
    
return 




;------------------------------------------------------------------------------- 
; Open link in new browser.
$n::
    Click, right
    Sleep, 200
    Send, ^w
return

;------------------------------------------------------------------------------- 
; Open link below mouse in new tab.
$t::
    Click, right
    Sleep, 10
    Send, {Down}
    Sleep, 10
    Send, {Enter}
return

;-------------------------------------------------------------------------------
; Close current tab.
; <Ctrl + w> => close tab in Firefox
$w::
    Send, ^w
return

;-------------------------------------------------------------------------------
; Click repeater.
;
; Hotkeys and labelled blocks seem to be able to use global variables by default.

clicking := false
clickX := 0
clickY := 0

Clicker:
    ;global
    Click %clickX%, %clickY%
return

$r::
    ;global
    if (clicking) {
        SetTimer, Clicker, off
        clicking := false
        MsgBox, , Repeater , Repeater disabled., 2 ; The message box will close itself after two seconds.
        return
    } ; if
    
    clicking := true
    MouseGetPos, clickX, clickY
    InputBox, delay, Click Delay, Enter the number of seconds to wait between clicks:`n(Default is 10 seconds)
    if (delay = "") {
        delay := 10
    }
    
    delay *= 1000 ; Seconds to milliseconds.
   
    SetTimer, Clicker, %delay%

return

;-------------------------------------------------------------------------------
; Automatic key presser.

; TODO: Allow an arbitrary key to be repeated.  Capture user input.
; TODO: Allow an arbitrary string to be repeated.  Capture user input.

repeating := true

KeyPresser:
    Send {Down}
    Send {Down}
return

$s::
    if (repeating) {
        SetTimer, KeyPresser, off
        repeating := false
        MsgBox, , Repeater , Repeater disabled., 1.5 ; The message box will close itself after two seconds.
        return
    } ; if
    
    repeating := true
    
    InputBox, delay, Click Delay, Enter seconds between repetitions:`n(Default is 2 seconds)
    if (delay = "") {
        delay := 2
    }
    
    delay *= 1000 ; Seconds to milliseconds.
   
    SetTimer, KeyPresser, %delay%

return





;-------------------------------------------------------------------------------
; Transparent
; <Ctrl + Alt + Space>
$^!Space::WinSet, Transparent, 125, A
$^!Space UP::WinSet, Transparent, OFF, A

;------------------------------------------------------------------------------- 
; Terminate this keystroke handler.  End this context.
LControl & Escape::
    SoundPlay %A_ScriptDir%\Sounds\Navigation_Exit.wav, Wait
ExitApp
