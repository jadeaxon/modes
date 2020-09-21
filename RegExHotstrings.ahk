/*
	March 13, 2020
	
	This RegExHotstringsApps.ahk script includes both the RegExHotstrings() function and a number of examples. The
	function interprets Regular Expressions (RegEx) and delivers the results as if a Hotstring. It monitors your keystrokes
	and activates when it sees a matched pattern.
	
	Enclose subpatterns within parentheses for use in text replacements or Label subroutines. Call the replacement
	values with $1, $2, $3, respective to their order in the RegEx. Unlike the AutoHotkey RegExReplace() function. The term
	$0 does not return the entire matching expression. (Use Ryan's RegEx Tester to view values.)
	
	You can now easily replicate many of the Hotstring text replacement examples with the built-in AutoHotkey Hotstring()
	function using the X (execute) option. However, the Hotstring() function does not accept Regular Expressions. Therefore,
	the RegExHotstrings() function allows the activating of creative Hotstrings such as, calculating percentages, addition
	and subtraction as shown in some of the examples.
	
	The included Add subroutine only adds and subtracts.
	
	April 3, 2020 Added two new examples for word manipulation: swapping two words and auto-delete duplicate word.
	See blog dated April 6, 2020.

	April 21, 2020 Added two more RegExHotstring examples: Capitualize current word and 
	repeat word or phrase
	
	See discussions on Jack's AutoHotkey Blog: https://jacks-autohotkey-blog.com/
*/

#Persistent

Menu, Tray, Icon, %A_ScriptDir%\Icons\RegExHotstrings.ico

RegExHotstrings:

; Jira ticket id to link.  AIS-1560 => https://uvu-it.atlassian.net/browse/AIS-1560 
RegExHotstrings("(AIS|ORCL|BUS|B9SA)-(\d+)l", "JiraLink")

; Ag(query) => Google the query.
RegExHotstrings("Ag\((.*)\)", "Google")


; Set a voice reminder n minutes from now.
; Ar2(<reminder to speak>, <minutes>)
RegExHotstrings("Ar2\((.*),(.*)\)", "VoiceReminder")

/*
; swap the last two words typed (including commas and connectors) (Try: that and this<)
RegExHotstrings("([\w'-]+)([,;]?\s(?:and\s|or\s)?)([\w'-]+)<", "%$3%%$2%%$1%")

; auto-delete duplicate word (Try: the the)
RegExHotstrings("(\b[\w-']+\b)\s+\1", "%$1%")

; capitalize current word, (Try: word^)
RegExHotstrings("(\b[\w-']+)\^", "CapWord")

; Repeat words and phrases (Try: Yes!3`) (Note: ` = Backtick)
RegExHotstrings("\b([[:alpha:]-'\s,]+)([!,.;?]?)(\d+)``", "Repeat")

; capitalize sentences following period, question mark, or exclamation point
; RegExHotstrings("(\.|\?|!)\s+(\w)", "Label")

; calculate percent—try: 4/50%
RegExHotstrings("(\d+(?:\.\d+)?)/(\d+(?:\.\d+)?)%", "percent")

RegExHotstrings("i)Show me\s*=\s*(.*?)\s*\.", "Result: %$1%%A_Space%") ; try: show me = #$&*_+{|<? .
RegExHotstrings("now#", "%A_Now%") ; try: now#
RegExHotstrings("(B|b)tw", "%$1%y the way") ; try: Btw or btw
RegExHotstrings("i)omg", "oh my god!") ; try: omg
RegExHotstrings("i)R\s*\>\s*(\d+)\s*&\s*\<\s*(\d+)\.","[R] > %$1% & R < %$2%") ; try: r>15&<20 .
RegExHotstrings("\bcolou?r", "rgb(128, 255, 0);") ; try: colour or color
*/

Return


JiraLink:
	output := "https://uvu-it.atlassian.net/browse/" . $1 . "-" . $2
	SendInput, {raw}%output%
return


Google:
	query := $1
	Run, http://www.google.com/search?q=%query%
	Sleep 500
	WinActivate ahk_exe firefox.exe
return


; BUG: This can only handle one reminder at a time.
VoiceReminder:
	reminder := trim($1)
	minutes := trim($2)
	minutes := round(abs(minutes), 0)
	millis := minutes * 60 * 1000
	millis := -millis ; Make it a one-shot timer.

	confirmation := "I will remind you to " . reminder . " in " . minutes . " "
	confirmation := confirmation . ((minutes = 1) ? "minute" : "minutes")
	COMObjCreate("SAPI.SpVoice").Speak(confirmation)
	SetTimer, VoiceReminderTimer, %millis%

return


VoiceReminderTimer:
	COMObjCreate("SAPI.SpVoice").Speak(reminder)
return
	

	


/*
Repeat:
OutputVar := ""
Loop %$3%
	OutputVar := OutputVar . $1 . $2 . " "
SendInput, {Raw}%OutputVar%
Return

Add:
AddArray := StrSplit($1 ,"+")
Total := 0
Loop % AddArray.MaxIndex()
{
	If InStr(AddArray[A_Index],"-")
	{
		SubArray := StrSplit(AddArray[A_Index],"-")
		SubTotal := SubArray[1]
		Loop % SubArray.MaxIndex()-1
		{
			SubTotal := SubTotal - SubArray[A_Index+1]
		}
		AddArray[A_Index] := SubTotal
	}
	Total := Total + AddArray[A_Index]
}

SendInput, % Format("{:g}", Total)

Return

CapWord:
  Stringupper, Cap, $1, T
  Sendinput, %Cap%
Return

Label:
  Stringupper, $2, $2
  Sendinput, % "{raw}" $1 " " $2
Return

Percent:
p := Round($1 / $2 * 100,1)
Send, %p%`%
Return
*/



/*
	Function: RegExHotstrings
	Dynamically adds regular expression hotstrings.
	
	Parameters:
	c - regular expression hotstring
	a - (optional) text to replace hotstring with or a label to goto,
	leave blank to remove hotstring definition from triggering an action
	
	Examples:
	> RegExHotstrings("(B|b)tw\s", "%$1%y the way") ; type 'btw' followed by space, tab or return
	> RegExHotstrings("i)omg", "oh my god!") ; type 'OMG' in any case, upper, lower or mixed
	> RegExHotstrings("\bcolou?r", "rgb(128, 255, 0);") ; '\b' prevents matching with anything before the word, e.g. 'multicololoured'
	
	License:
	- RegEx Dynamic Hotstrings: Modified version by Edd
	- Original:
	- Dedicated to the public domain (CC0 1.0)
*/

RegExHotstrings(k, a = "", Options:="")
{
	static z, m = "~$", m_ = "*~$", s, t, w = 2000, sd, d = "Left,Right,Up,Down,Home,End,RButton,LButton", f = "!,+,^,#", f_="{,}"
	global $
	If z = ; init
	{
		RegRead, sd, HKCU, Control Panel\International, sDecimal
		Loop, 94
		{
			c := Chr(A_Index + 32)
			If A_Index between 33 and 58
				Hotkey, %m_%%c%, __hs
			else If A_Index not between 65 and 90
				Hotkey, %m%%c%, __hs
		}
		e = 0,1,2,3,4,5,6,7,8,9,Dot,Div,Mult,Add,Sub,Enter
		Loop, Parse, e, `,
			Hotkey, %m%Numpad%A_LoopField%, __hs
		e = BS,Shift,Space,Enter,Return,Tab,%d%
		Loop, Parse, e, `,
			Hotkey, %m%%A_LoopField%, __hs
		z = 1
	}
	If (a == "" and k == "") ; poll
	{
		q:=RegExReplace(A_ThisHotkey, "\*\~\$(.*)", "$1")
		q:=RegExReplace(q, "\~\$(.*)", "$1")
		If q = BS
		{
			If (SubStr(s, 0) != "}")
				StringTrimRight, s, s, 1
		}
		Else If q in %d%
			s =
		Else
		{
			If q = Shift
				return
			Else If q = Space
				q := " "
			Else If q = Tab
				q := "`t"
			Else If q in Enter,Return,NumpadEnter
				q := "`n"
			Else If (RegExMatch(q, "Numpad(.+)", n))
			{
				q := n1 == "Div" ? "/" : n1 == "Mult" ? "*" : n1 == "Add" ? "+" : n1 == "Sub" ? "-" : n1 == "Dot" ? sd : ""
				If n1 is digit
					q = %n1%
			}
			Else If (GetKeyState("Shift") ^ !GetKeyState("CapsLock", "T"))
				StringLower, q, q
			s .= q
		}
		Loop, Parse, t, `n ; check
		{
			StringSplit, x, A_LoopField, `r
			If (RegExMatch(s, x1 . "$", $)) ; match
			{
				StringLen, l, $
				StringTrimRight, s, s, l
				if !(x3~="i)\bNB\b")        ; if No Backspce "NB"
					SendInput, {BS %l%}
				If (IsLabel(x2))
					Gosub, %x2%
				Else
				{
					Transform, x0, Deref, %x2%
					Loop, Parse, f_, `,
						StringReplace, x0, x0, %A_LoopField%, ¥%A_LoopField%¥, All
					Loop, Parse, f_, `,
						StringReplace, x0, x0, ¥%A_LoopField%¥, {%A_LoopField%}, All
					Loop, Parse, f, `,
						StringReplace, x0, x0, %A_LoopField%, {%A_LoopField%}, All
					SendInput, %x0%
				}
			}
		}
		If (StrLen(s) > w)
			StringTrimLeft, s, s, w // 2
	}
	Else ; assert
	{
		StringReplace, k, k, `n, \n, All ; normalize
		StringReplace, k, k, `r, \r, All
		Loop, Parse, t, `n
		{
			l = %A_LoopField%
			If (SubStr(l, 1, InStr(l, "`r") - 1) == k)
				StringReplace, t, t, `n%l%
		}
		If a !=
			t = %t%`n%k%`r%a%`r%Options%
	}
	Return
	__hs: ; event
	RegExHotstrings("", "", Options)
	Return
}
