# AHK Modes
AHK app to provide various modes to Windows (like Vim has modes).

## Deployment

Simply have this repo cloned to in `~/projects/modes/`.

Create a link so that it autostarts on boot after everything else:<br>
`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Z Master.ahk.lnk`

Copy the appropriate `Symbols_<resolution>` folder to a folder named `Symbols`.<br>
You'll need to make a new `Symbols_<resolution>` folder for each different monitor size you run this
on.  Also, be aware that you cannot change the Windows DPI settings or else everything will fail.


