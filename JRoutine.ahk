; Automates transitions between workflow stages when you hit <A n>.
; Supports periodic routines where you move from one app/location to the next.

;==============================================================================
; JRoutine Workflow Transitions
;==============================================================================

; <A n> => Move to next workflow stage in daily routine (or other current multiapp workflow).
#IfWinActive Slack - UVU IT
$!n::
	Run http://www.google.com
	WinWait Google
	WinActivate Google
	WinWaitActive Google
	; I don't think sending <A n> here will work since $ blocks retriggering.
	Send ^l
	Sleep 200
	Send https://slashdot.org/
	Send {Enter}
return

; <A n> => open next bookmark
#IfWinActive Google - Mozilla Firefox ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send https://slashdot.org/
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark
#IfWinActive Slashdot ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send https://news.ycombinator.com/
	Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Hacker News ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send http://lifehacker.com/
	Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Lifehacker ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send http://dilbert.com/
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark
#IfWinActive Dilbert ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send https://www.hotmail.com
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark.  @Now GTD context and personal kanban.
#IfWinActive  Mail - Jeffrey Anderson ahk_class MozillaWindowClass
$!n::
	EnvGet, home, USERPROFILE
	file := home . "\Dropbox\Organization\To Do\Contexts\Home\@Now.txt"
	Run %file%
	; Run "C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Home\@Now.txt"
	; For some reason, this does not work.
	; WinActivate Mail - jadeaxon@hotmail.com - Mozilla Firefox
	WinWait @Now
	WinActivate @Now
	WinWaitActive @Now
	Send !{Tab}
	WinWaitActive Mail
	Send ^l
	Sleep 200
	; Personal Kanban
	Send https://docs.google.com/spreadsheets/d/1zXpRv6WFdb9eX9YDerTTCE7L3N6InYxJ-FYec9ok79I/edit{#}gid=0
	Send {Enter}
	Send ^t
	Sleep 1000
	Send ^l
	Sleep 200
	; Work Kanban
	Send https://docs.google.com/spreadsheets/d/1mA2Xi0Vzr-Ax9ejSXg8_kV1CoYwDt-a_c4Q6Eah16Z0/edit{#}gid=0
	Sleep 200	
	Send {Enter}
	Sleep 200
	Send ^{Tab}
return
#IfWinActive



