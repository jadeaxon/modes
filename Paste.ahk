; This mode creates a window that maps each letter of the alphabet to a string.
; When any other window is active, pressing the letter pastes the string.
; When this window is active, you can assign a new string to a letter.

;=============================================================================== 
; MAIN
;===============================================================================

alphabet := "a b c d e f g h i j k l m n o p q r s t u v w x y z"
StringSplit, letters, alphabet, %A_Space%

; _writeHotkeyCode()

editY := 5
textY := editY + 3
deltaY := 25

; the zeroeth element of the "array" contains its size
Loop, %letters0% {
    letter := letters%a_index%
	
	; StringUpper, ucLetter, letter 
    ; MsgBox, Letter %a_index% is %ucLetter%.
	
	Gui, Add, Text, x5 y%textY%, %letter%
	Gui, Add, Edit, x17 gEditEvent y%editY% v%letter%_string w150, 
	; don't include the 'v' and the 'g' in the variable and label 
	
	editY += deltaY
	textY := editY + 3
	
} ; next letter

Gui +AlwaysOnTop
Gui +LastFound ; Aim AHK's window manipulation functions at this GUI.
guiHandle := 0
WinGet, guiHandle, ID
WinSetTitle Paste
Gui Show



; Updates the field linked variables.
EditEvent:
	; TODO: Really only need to submit on window losing focus.
	Gui, Submit, NoHide
return
 

;=============================================================================== 
; FUNCTIONS
;=============================================================================== 

; Writes the boilerplate code for each hotkey.
; $a::
;	_processKeystroke("a")
; return
_writeHotkeyCode() {
	; Using global array in a funtion doesn't work so well because you'd have to declare every element.
	alphabet := "a b c d e f g h i j k l m n o p q r s t u v w x y z"
	StringSplit, letters, alphabet, %A_Space%

	Run Notepad.exe
	WinWait Untitled - Notepad
	WinActivate Untitled - Notepad
	WinWaitActive Untitled - Notepad
	Loop, %letters0% {
		letter := letters%a_index%
		Send $%letter%::{Enter} 
		Send {Space 4}_processKeystroke("%letter%"){Enter} 
		Send return{Enter}{Enter} 
		
	} ; next letter
	
} ; _writeHotkeyCode()


 _processKeystroke(keystroke) {
	global guiHandle
	
	; If the active window is this mode's GUI, pass the keystroke through without expansion
	activeWindow := WinExist("A")
	; MsgBox,,, %activeWindow% %guiHandle%
	if (activeWindow = guiHandle) {
		; MsgBox,,, %keystroke%
		Send %keystroke%
		return
	}
	
	Clipboard := %keystroke%_string
	Sleep 100
	Send, ^v
	
	return

} ; _processKeystroke(keystroke)


 
;=============================================================================== 
; HOTKEYS
;=============================================================================== 

; Generated by _writeHotkeyCode()

$a::
    _processKeystroke("a")
return

$b::
    _processKeystroke("b")
return

$c::
    _processKeystroke("c")
return

$d::
    _processKeystroke("d")
return

$e::
    _processKeystroke("e")
return

$f::
    _processKeystroke("f")
return

$g::
    _processKeystroke("g")
return

$h::
    _processKeystroke("h")
return

$i::
    _processKeystroke("i")
return

$j::
    _processKeystroke("j")
return

$k::
    _processKeystroke("k")
return

$l::
    _processKeystroke("l")
return

$m::
    _processKeystroke("m")
return

$n::
    _processKeystroke("n")
return

$o::
    _processKeystroke("o")
return

$p::
    _processKeystroke("p")
return

$q::
    _processKeystroke("q")
return

$r::
    _processKeystroke("r")
return

$s::
    _processKeystroke("s")
return

$t::
    _processKeystroke("t")
return

$u::
    _processKeystroke("u")
return

$v::
    _processKeystroke("v")
return

$w::
    _processKeystroke("w")
return

$x::
    _processKeystroke("x")
return

$y::
    _processKeystroke("y")
return

$z::
    _processKeystroke("z")
return


;------------------------------------------------------------------------------- 
; Terminate this keystroke handler.  End this context.
LControl & Escape::
	Gui, Destroy
    ; SoundPlay C:\Users\Jade Axon\Desktop\AHK\Navigation_Exit.wav, Wait
ExitApp

GuiClose:
	Gui, Destroy
ExitApp



