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
	Send https://slashdot.org/
	Send {Enter}
return

; <A n> => open next bookmark
#IfWinActive Google - Mozilla Firefox ahk_class MozillaWindowClass
$!n::
   Send ^l
   Send https://slashdot.org/
   Send {Enter}
return
#IfWinActive  


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
#IfWinActive Dilbert ahk_class MozillaWindowClass
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
	Send https://www.hotmail.com
	Send {Enter}
return
#IfWinActive  

#IfWinActive Mail - jadeaxon@hotmail.com - Mozilla Firefox ahk_class MozillaWindowClass
$!n::
	Send ^l
	Send https://jobs.utah.gov/jsp/utahjobs/seeker/home/viewHome.do
	Send {Enter}
return
#IfWinActive

; <A n> => open next bookmark.  @Now GTD context and personal kanban.
#IfWinActive jobs.utah.gov ahk_class MozillaWindowClass
$!n::
	Run "C:\Users\jadeaxon\Dropbox\Organization\To Do\Contexts\Home\@Now.txt"
	; For some reason, this does not work.
	; WinActivate Mail - jadeaxon@hotmail.com - Mozilla Firefox
	WinWait @Now
	WinActivate @Now
	WinWaitActive @Now
	Send !{Tab}
	WinWaitActive jobs.utah.gov	
	Send ^l
	Send https://docs.google.com/spreadsheets/d/1zXpRv6WFdb9eX9YDerTTCE7L3N6InYxJ-FYec9ok79I/edit{#}gid=0
	Send {Enter}
return
#IfWinActive

; Done with kanban => read dictionary for a while.
#IfWinActive Personal Kanban ahk_class MozillaWindowClass
$!n::
	OpenKindleBook("Merriam-Webster's Dictionary")
return

#IfWinActive


