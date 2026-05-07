# AHK Modes
2026-05-07: Updated to AHK v2.

AHK app to provide various modes to Windows (like Vim has modes). Mainly it just runs in one mode that fixes a pile of things that bug me in Windows and makes things I need to do in various apps more efficient. The original idea for a secondary mode was a mouseless web browsing mode (navigation mode). There is also a debug mode which is the only extra mode I kept in v2.

The nice thing is whatever mode you are in can be escaped by hitting <C Esc>. So, you really end up with a stack of modes where each mode is an AHK script that shadows anything else running. When you are in the main mode, <C Esc> reloads the main script (Master_v2.ahk) from disk. This is nice when you have quick edits you want to test.

Another niche mode in v1 that got developed was Gaunlet mode which I used to map all the wizard spells in Gauntlet to individual keystrokes. Usually you'd have to press some button sequence which I'd always forget in the heat of battle.  

## Deployment

Simply have this repo cloned to in `~/projects/modes/`.

Create a link so that it autostarts on boot after everything else:<br>
`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Z Master_v2.ahk.lnk`

Use `<W r>shell:startup` to open that folder.<br>

If you are in Cygwin and using bash-glory, typing just `.` in the project dir will reload Master_v2.ahk.<br>
It's generally easier to just type <C Esc> though.

