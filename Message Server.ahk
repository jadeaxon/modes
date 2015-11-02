; Load this timer after the icon or else the icon won't load.
; Poll the status of Vim every ??? ms to see if we should enable/disable ShortKeys.
; 100 ms seems fast enough.  Very responsive.  Doesn't appear to burden CPU at all.
; 200 ms feels a tad bit too slow.
;
; PRE: RAM disk R:\ must exist and be writable.
; PRE: For this to work, ShortKeys.vim must have been sourced in Vim.  This enables autocommands which update the vim_status.txt file.  

; Let's see if we can make a general message server.

; We read from an event queue.  It is just a directory on a RAM disk:
; R:\AHK Message Queue
;
; Each file is a message.  It contains code to execute in AHK verbatim.  Dynamic code.

; It is a FIFO queue based on file creation (modification) time.
; When a message is consumed, its file is deleted.

; To get a unique temporary file name for the queue, a client starts naming files message1.ahk, message2.ahk, etc. until it finds a file name
; not in use.

; #Persistent
; #Include %A_ScriptDir%\Library.ahk



; So, can we simply execute AHK code stored in a string?

; Q. How do I make this stuff not execute if this file is included?
; Else I get essentially a fork bomb.

; MsgBox,,, %code%
; DynaRun(code, "AHK Event Queue")
; DynaRun("#Include " . A_ScriptDir . "\Test.ahk`nUserFunction()", "AHK Event Queue")

; While we can't execute arbitrary dynamic code, we can dynamically call a function.  Which is good enough.
; Now, we have context and no process overhead.  We can read the function to call from a file.
; function := "UserFunction"
; %function%()

; To handle arguments, you'd have to do something like
; if (args == 1) %function%(arg1)
; if (args == 2) %function%(arg1, arg2)
; etc.
; You'd have to set some practical limit on the number of arguments that can be passed to the function.

; Q. Can I do multiline quotes in AHK?


;=============================================================================== 
; FUNCTIONS
;===============================================================================

ProcessNextMessage() {
	message := GetOldestMessage()
	; MsgBox,,, Message: %message%

	if (message) {
		; Assume message is in the from "SomeFunction()".
		; So, let's strip off the () and dynamically call the function.
		StringReplace, function, message, (, , All
		StringReplace, function, function, ), , All

		; MsgBox,,, Calling %function%
		%function%()
	}

} ; ProcessNextMessage()


; Find the oldest file in the AHK message queue directory.
; Read its contents and then delete it.  Its contents is the next message to process.  The oldest message (first in).
GetOldestMessage() {
	; WARNING: This caused my autoexec.bat to get deleted!
	; WARNING: Do not rely on global variables in libraries meant for inclusion.  Only use them in top level scripts.
	; global messageQueueDirectory
	; For some reason when included, this global variable doesn't work whereas when run as a script it does.
	
	messageQueueDirectory := "R:\AHK Message Queue"

	; This selects the oldest message file (by creation date) in the message queue folder.
	oldestMessageFile := ""
	Loop %messageQueueDirectory%\* {
		if (oldestMessageFile == "") {
			oldestMessageFile := A_LoopFileFullPath
		}
		
		FileGetTime, oldestCreationTime, oldestMessageFile, C
		

		if (A_LoopFileTimeCreated < oldestCreationTime) {
			oldestMessageFile := A_LoopFileFullPath
			oldestCreationTime := A_LoopFileTimeCreated
		}
		

	} ; next file

	; MsgBox,,, %oldestMessageFile%

	oldestMessage := ""
	if ( FileExist(oldestMessageFile) ) {
		FileRead, oldestMessage, %oldestMessageFile%
		if not ErrorLevel  {  ; Successfully loaded.
			; See AutoTrim.
			oldestMessage = %oldestMessage% ; This trims leading and trailing whitespace.  But not newlines, I guess.
			StringReplace, oldestMessage, oldestMessage, `n, , All
		
			if ( FileExist(oldestMessageFile) ) {
				FileDelete %oldestMessageFile%
			}
			
		}
		else { ; Some kind of error happened.
			oldestMessage := ""
		}
		
		
	} ; if
	
	; MsgBox,,, Oldest message: "%oldestMessage%"
	return oldestMessage
	
} ; GetOldestMessage()


