; https://www.autohotkey.com/docs/commands/ListView.htm
; https://www.autohotkey.com/docs/Variables.htm#BuiltIn

Gui +Resize
Gui, Add, ListView, r40 w1000, Category|Variable|Value|Description
LV_Add("", "OS", "A_OSVersion", A_OSVersion, "The version of your operating system.")
LV_Add("", "OS", "A_ComSpec", A_ComSpec, "The path to your OS command interpreter.")
LV_Add("", "OS", "A_Temp", A_Temp, "The directory where temp files are stored.")
LV_Add("", "OS", "A_OSType", A_OSType, "The type of your operating system.")
LV_Add("", "OS", "A_Is64bitOS", A_Is64bitOS, "Are you running a 64-bit OS?")
LV_Add("", "OS", "A_PtrSize", A_PtrSize, "Pointer size in bytes.")
LV_Add("", "OS", "A_Language", A_Language, "The default language setting for the OS as a 4-digit code.")
LV_Add("", "OS", "A_ComputerName", A_ComputerName, "The name of this computer.")
LV_Add("", "OS", "A_UserName", A_UserName, "The user name of the current user.")
LV_Add("", "OS", "A_WinDir", A_WinDir, "The Windows directory.")
LV_Add("", "OS", "A_ProgramFiles", A_ProgramFiles, "The Windows program files directory.")
LV_Add("", "OS", "A_AppData", A_AppData, "The current user's application data directory.")
LV_Add("", "OS", "A_AppDataCommon", A_AppDataCommon, "Folder for application data common to all users.")
LV_Add("", "OS", "A_Desktop", A_Desktop, "Current user's desktop folder.")
LV_Add("", "OS", "A_DesktopCommon", A_DesktopCommon, "Folder when items common to all users' desktops are stored.")
LV_Add("", "OS", "A_StartMenu", A_StartMenu, "Current user's start menu folder.")
LV_Add("", "OS", "A_StartMenuCommon", A_StartMenuCommon, "Start menu items for all users.")
LV_Add("", "OS", "A_Programs", A_Programs, "Start menu programs for current user.")
LV_Add("", "OS", "A_ProgramsCommon", A_ProgramsCommon, "Start menu programs for all users.")
LV_Add("", "OS", "A_Startup", A_Startup, "Folder of stuff to run at startup for current user.")
LV_Add("", "OS", "A_StartupCommon", A_StartupCommon, "Folder of stuff to run at startup for all users.")
LV_Add("", "OS", "A_MyDocuments", A_MyDocuments, "Current user's documents folder.")
LV_Add("", "OS", "A_IsAdmin", A_IsAdmin, "Is the current user an administrator?")
LV_Add("", "OS", "A_ScreenWidth", A_ScreenWidth, "Width of the screen.")
LV_Add("", "OS", "A_ScreenHeight", A_ScreenHeight, "Height of the screen.")
LV_Add("", "OS", "A_ScreenDPI", A_ScreenDPI, "Pixels per logical inch.")
LV_Add("", "OS", "A_IPAddress1", A_IPAddress1, "IP address of your first network interface.")
LV_Add("", "Mouse", "A_Cursor", A_Cursor, "Type of mouse cursor being displayed.")
LV_Add("", "Mouse", "A_CaretX", A_CaretX, "Mouse x coordinate at text insertion point.")
LV_Add("", "Mouse", "A_CaretY", A_CaretY, "Mouse y coordinate at text insertion point.")
LV_Add("", "OS", "Clipboard", Clipboard, "Text contents of the clipboard.")
; LV_Add("", "OS", "ClipboardAll", ClipboardAll, "Entire contents of the clipboard.")
LV_Add("", "AHK", "ErrorLevel", ErrorLevel, "Error level set by last AHK command.")
LV_Add("", "OS", "A_LastError", A_LastError, "Last error returned from a DLL call.")
LV_Add("", "AHK", "true", true, "Builtin constant for true (value is 1).")
LV_Add("", "AHK", "false", false, "Builtin constant for false (value is 0).")
LV_Add("", "Loop", "A_Index", A_Index, "Current 1-based loop iteration count.")
LV_Add("", "Loop", "A_LoopFileName", A_LoopFileName, "Name of file when doing a files loop.")
LV_Add("", "Loop", "A_LoopRegName", A_LoopRegName, "Registry key when doing a registry loop.")
LV_Add("", "Loop", "A_LoopReadLine", A_LoopReadLine, "The read line when doing a file reading loop.")
LV_Add("", "Loop", "A_LoopField", A_LoopField, "The parsed field when doing a line parsing loop.")
LV_Add("", "Menu", "A_ThisMenuItem", A_ThisMenuItem, "The most recently selected custom menu item.")
LV_Add("", "Menu", "A_ThisMenu", A_ThisMenu, "The menu which A_ThisMenuItem belongs to.")
LV_Add("", "Menu", "A_ThisMenuItemPos", A_ThisMenuItemPos, "The 1-based position of A_ThisMenuItem within A_ThisMenu.")
LV_Add("", "Hotkey", "A_ThisHotkey", A_ThisHotkey, "The triggering string for currently activated hotkey.")
LV_Add("", "Hotkey", "A_PriorHotkey", A_PriorHotkey, "The triggering string for the previous activated hotkey.")
LV_Add("", "Keyboard", "A_PriorKey", A_PriorKey, "The last key that was pressed.")
LV_Add("", "AHK", "A_Space", A_Space, "A space character.") 
LV_Add("", "AHK", "A_Tab", A_Tab, "A tab character.") 
LV_Add("", "AHK", "A_Args", A_Args, "Command-line args.") 
LV_Add("", "AHK", "A_WorkingDir", A_WorkingDir, "Current working directory of this script.") 
LV_Add("", "AHK", "A_ScriptDir", A_ScriptDir, "The directory where this script lives.") 
LV_Add("", "AHK", "A_ScriptName", A_ScriptName, "The name of this script (including extension).") 
LV_Add("", "AHK", "A_ScriptFullPath", A_ScriptFullPath, "The full path to this script.") 
LV_Add("", "AHK", "A_ScriptHwnd", A_ScriptHwnd, "The id of the main window of this script (tray menu Open, not Gui)") 
LV_Add("", "AHK", "A_LineNumber", A_LineNumber, "Currently executing line number in A_LineFile.") 
LV_Add("", "AHK", "A_LineFile", A_LineFile, "The file in which line A_LineNumber is executing.") 
LV_Add("", "AHK", "A_ThisFunc", A_ThisFunc, "Name of the current function.") 
LV_Add("", "AHK", "A_ThisLabel", A_ThisLabel, "Name of the current label (aka, subroutine).") 
LV_Add("", "AHK", "A_AhkVersion", A_AhkVersion, "The version of the AHK interpreter that is running this script.") 
LV_Add("", "AHK", "A_AhkPath", A_AhkPath, "Path to the AHK interpreter executable.") 
LV_Add("", "AHK", "A_IsUnicode", A_IsUnicode, "Was AHK compiled to use Unicode?") 
LV_Add("", "AHK", "A_IsCompiled", A_IsCompiled, "Is this a compiled (standalone) script?") 
LV_Add("", "AHK", "A_ExitReason", A_ExitReason, "Why the script was asked to terminate.") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_Add("", "", "", , "") 
LV_ModifyCol() ; Autosize all columns to fit data.

Gui, Show



