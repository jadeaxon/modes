# AHK Modes
AHK app to provide various modes to Windows (like Vim has modes).  Mainly it just runs in one mode that fixes a pile of things that bug me in Windows and makes things I need to do in various apps more efficient.  The original idea for a secondary mode was a mouseless web browsing mode (navigation mode).  That does exist to something along with a debug mode.

The nice thing is whatever mode you are in can be escaped by hitting <C Esc>.  So, you really end up with a stack of modes where each mode is an AHK script that shadows anything else running.  When you are in the main mode, <C Esc> reloads the main script (Master.ahk) from disk.  This is nice when you have quick edits you want to test.

Another niche mode that got developed was Gaunlet mode which I used to map all the wizard spells in Gauntlet to individual keystrokes.  Usually you'd have to press some button sequence which I'd always forget in the heat of battle.  

## Deployment

Simply have this repo cloned to in `~/projects/modes/`.

Create a link so that it autostarts on boot after everything else:<br>
`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Z Master.ahk.lnk`

Copy the appropriate `Symbols_<resolution>` folder to a folder named `Symbols`.<br>
You'll need to make a new `Symbols_<resolution>` folder for each different monitor size you run this
on.  Also, be aware that you cannot change the Windows DPI settings or else everything will fail.


