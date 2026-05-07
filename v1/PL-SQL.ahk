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

:*:Sx::SELECT
:*:Fx::FROM
:*:Wx::WHERE

:*:Nx::NULL

:*:Lx::LOOP
:*:ELx::END LOOP;

; if is null then
; Unfortunately, the behavior is not the same for actual typed keystrokes.
; When in an intented region of code, this does not work via hotstring.
::IFint::
	Send IF IS NULL THEN`n
	Sleep 300
	Send `t`n
	Sleep 300
	Send END IF;`n
	Sleep 300
	Send {Up}{Up}{Up}{Right}{Right}
	Send {Space}
return


; if is null then else
::IFinte::
	Send IF IS NULL THEN`n
	Send `t`n
	Send ELSE`n
	Send `t`n
	Send END IF;`n
	Send {Up 5}{Right}{Right}
	Send {Space}
return

; if is not null then
::IFinnt::
	Send IF IS NOT NULL THEN`n
	Send `t`n
	Send END IF;`n
	Send {Up}{Up}{Up}{Right}{Right}
	Send {Space}
return

:*:EIx::END IF;

:*:Rx::RETURN;

:*:VCx::VARCHAR2(){left}
:*:Vt::VARCHAR2(){left}
:*:CVt::CONSTANT VARCHAR2(){left}
:*:Bt::BOOLEAN

:*:%t::%TYPE
:*:%rt::%ROWTYPE


#IfWinActive


