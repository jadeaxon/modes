; Abbreviation expansion similar to (but more poverful than) what ShortKeys does. 

;-------------------------------------------------------------------------------
; Remap {Left} to my keyboard's left arrow.
; {Left} => Numpad4 on this laptop for some reason.
; vk25  sc14B => left arrow
VK64::
	Send, {vk25sc14B}
return

; Remap {Down} to my keyboard's down arrow.
VK68::
	Send, {vk28sc150}
return

;-------------------------------------------------------------------------------
; jw => Java while loop.  Cursor ends up between the parens.
:O:jw::while () {{}{enter}{enter}{}} // next{enter}{Left 15}
return


;-------------------------------------------------------------------------------
; Ctrl x to exit.
LControl & Escape::

ExitApp

