; Opens given book in Kindle desktop app.
OpenKindleBook(book)
{
	Run "C:\Users\jadeaxon\AppData\Local\Amazon\Kindle\application\Kindle.exe"
	; File|Go|Library
	WinWait Jeff's Kindle
	WinActivate Jeff's Kindle
	WinWaitActive Jeff's Kindle
	WinMaximize Jeff's Kindle
	Sleep 2000
	Send !g
	Sleep 500
	Send {Enter}
	Sleep 500

	MouseMove 330, 80
	Click
	Send %book%{Enter}
	Sleep 500

	MouseMove 350, 200
	Click 2
}

; OpenKindleBook("Agile Project Management for Dummies")
OpenKindleBook("Merriam-Webster's Dictionary")


