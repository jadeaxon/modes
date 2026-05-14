#Requires AutoHotkey v2.0

#Include <StringPlus>

opener_id := ""
opener_child_id := ""

open_opener() {
	global opener_id

	opener_id := WinExist("Opener ahk_exe AutoHotkey64.exe")
	if opener_id {
		close_opener()
		return
	}
	
    ui := Gui("+AlwaysOnTop", "Opener")
	opener_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
    
    ; Add buttons for common directories
    ui.Add("Button", "w200", "&Directories").OnEvent("Click", (*) => open_directory_opener())
    ui.Add("Button", "w200", "&Files").OnEvent("Click", (*) => open_file_opener())
    ui.Add("Button", "w200", "&Apps").OnEvent("Click", (*) => open_app_opener())
    ui.Add("Button", "w200", "&URLs").OnEvent("Click", (*) => open_url_opener())
    ui.Add("Button", "w200", "&Settings").OnEvent("Click", (*) => open_settings_opener())
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()
}

open_directory_opener() {
	global opener_id
	global opener_child_id
	
	GuiFromHwnd(opener_id).Hide()
    ui := Gui("+AlwaysOnTop", "Directory Opener")
	opener_child_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
    
    ; Add buttons for common directories
    ui.Add("Button", "w200", "&Home").OnEvent("Click", (*) => open(HOME))
    ui.Add("Button", "w200", "&Downloads").OnEvent("Click", (*) => open(A_MyDocuments . "\..\Downloads"))
    ui.Add("Button", "w200", "&Screenshots").OnEvent("Click", (*) => open(A_MyDocuments . "\..\Pictures\Screenshots"))
    ui.Add("Button", "w200", "&Google Drive").OnEvent("Click", (*) => open("G:\My Drive"))
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()

}

open_file_opener() {
	global opener_id
	global opener_child_id
	
	GuiFromHwnd(opener_id).Hide()
    ui := Gui("+AlwaysOnTop", "File Opener")
	opener_child_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
    
    ui.Add("Button", "w200", "&Exercise Routine").OnEvent("Click", (*) => open_exercise_routine())
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()
}

open_app_opener() {
	global opener_id
	global opener_child_id

	GuiFromHwnd(opener_id).Hide()
    ui := Gui("+AlwaysOnTop", "App Opener")
	opener_child_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
    
    ui.Add("Button", "w200", "&Firefox").OnEvent("Click", (*) => open("firefox.exe"))
    ui.Add("Button", "w200", "&Chrome").OnEvent("Click", (*) => open("chrome.exe"))
    ui.Add("Button", "w200", "&Outlook").OnEvent("Click", (*) => open("olk.exe"))
    ui.Add("Button", "w200", "&Kindle").OnEvent("Click", (*) => open("Kindle.exe"))
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()
}

open_url_opener() {
	global opener_id
	global opener_child_id

	GuiFromHwnd(opener_id).Hide()
    ui := Gui("+AlwaysOnTop", "App Opener")
	opener_child_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
    
    ui.Add("Button", "w200", "&Amazon").OnEvent("Click", (*) => open("https://www.amazon.com"))
    ui.Add("Button", "w200", "&Facebook").OnEvent("Click", (*) => open("https://www.facebook.com"))
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()
}

open_settings_opener() {
	global opener_id
	global opener_child_id

	GuiFromHwnd(opener_id).Hide()
    ui := Gui("+AlwaysOnTop", "Settings Opener")
	opener_child_id := ui.hwnd
    ui.SetFont("s10", "Segoe UI")
   
	env_vars := "rundll32.exe sysdm.cpl,EditEnvironmentVariables"
    ui.Add("Button", "w200", "&Environment Variables").OnEvent("Click", (*) => open(env_vars))
    
	ui.OnEvent("Escape", (uio) => uio.Destroy())
    ui.OnEvent("Close", (uio) => uio.Destroy())
    
    ui.Show()
}

on_system_path(file) {
	try {
		RunWait(A_ComSpec " /c where " file " >nul 2>nul", , "Hide")
		return true
	} 
	catch {
		return false
	}
}


; Helper function for the various opener popups.
open(path) {
	s := StringPlus(path)
	parts := s.split()
	command := parts[1]
	close_opener()
    if DirExist(path) {
        Run(path)
	}
	else if on_system_path(command) {
		if WinExist("ahk_exe " path) {
			WinActivate("ahk_exe " path)
		}
		else {
			if parts.length > 1 {
				; When you pass a command with args to Run, it changes how Run interprets its args.
				command := path
				Run(command)
			}
			else if s.startswith("https://") {
				url := path
				Run(url)
			}
			else {
				; Single app executable. Run maximized.
				app := path
				Run(app,,, "Max")
			}
		}
    } 
	else {
        MsgBox("Can't open/run path/command: " . path, "Error", "Icon!")
    }
}

; Helper function for opener popup.
open_exercise_routine() {
    BaseDir := "G:\My Drive\Organization\To Do\Checklists\Exercise Routine"
    LatestDate := ""
    
    ; 1. Find the newest YYYY-MM-DD folder using StrCompare to avoid math errors
    Loop Files, BaseDir "\*", "D" {
        if (RegExMatch(A_LoopFileName, "^\d{4}-\d{2}-\d{2}$")) {
            if (LatestDate == "" || StrCompare(A_LoopFileName, LatestDate) > 0) {
                LatestDate := A_LoopFileName
            }
        }
    }

    if (LatestDate == "") {
        MsgBox("No date-formatted folders found.")
        return
    }

    ; 3. Perform your custom mapping (1=Sun -> 7, others shift down)
    CustomDayNum := (A_WDay = 1) ? 7 : A_WDay - 1
    
    ; 4. Get the full name (e.g., Monday)
    DayName := FormatTime(, "dddd")
    
    ; 5. Construct the filename
    DayFileName := "@" . CustomDayNum . " " . DayName . ".txt"
    FilePath := BaseDir . "\" . LatestDate . "\" . DayFileName

    if FileExist(FilePath) {
        Run(FilePath)
    } 
	else {
        MsgBox("File not found:`n" . FilePath)
    }
	close_opener()

} ; open_exercise_routine()

close_opener() {
	global opener_id
	global opener_child_id

	; Close the GUI after a selection is made.
	if WinExist("ahk_id " . opener_child_id) {
		WinClose("ahk_id " . opener_child_id)
		opener_child_id := ""
	}
	if WinExist("ahk_id " . opener_id) {
		WinClose("ahk_id " . opener_id)
		opener_id := ""
	}
}


