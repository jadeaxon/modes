; Automates transitions between workflow stages when you hit <A n>.
; Supports periodic routines where you move from one app/location to the next.

;==============================================================================
; JRoutine Workflow Transitions
;==============================================================================

; <A n> => Move to next workflow stage in daily routine (or other current multiapp workflow).
#IfWinActive Slack - digEcor
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
	Send https://www.history.com/this-day-in-history
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark
#IfWinActive This Day in History ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send https://nationaldaycalendar.com/latest-posts/
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark
#IfWinActive Today - National Day Calendar ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	Send http://www.merriam-webster.com/word-of-the-day/
	Send {Enter}
return
#IfWinActive  


; <A n> => open next bookmark
#IfWinActive Word of the Day ahk_class MozillaWindowClass
$!n::
	Send ^l
	Sleep 200
	; Somehow they botched their site such that you can't directly link to random quotes.
	Send http://www.quotationspage.com/qotd.html
	Send {Enter}
return
#IfWinActive  

; <A n> => open next bookmark
#IfWinActive Quotes of the Day ahk_class MozillaWindowClass
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

; Done with kanban => read dictionary for a while.
#IfWinActive Personal Kanban ahk_class MozillaWindowClass
$!n::
	OpenKindleBook("Merriam-Webster's Dictionary")
return

$!p::
	file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\Home\Progress (Home).txt
	Run %file%
return

#IfWinActive

#IfWinActive Work Kanban ahk_class MozillaWindowClass
$!p::
	file = C:\Users\%A_UserName%\Dropbox\Organization\Progress\UVU\%A_YYYY%\Progress (UVU).txt
	Run %file%
return

#IfWinActive


