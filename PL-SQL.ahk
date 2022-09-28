; Case-sensitive hotstrings.
#Hotstring c

:*:ps.o::dbms_output.put_line();{left}{left}
:*:ps.sso::SET SERVEROUTPUT ON;

#IfWinActive Toad for Oracle ahk_exe Toad.exe
:*:DBEx::
	Send DECLARE`n
	Send BEGIN`n
	Send `tNULL;`n
	Send END; `n
	Send /`n
	Send {Up 4}`n
	Send {Up}`t
return

:*:Dx::DECLARE
:*:Bx::BEGIN
:*:Ex::END;

:*:VCx::VARCHAR2(){left}


#IfWinActive


