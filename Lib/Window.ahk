#Requires AutoHotkey v2.0

class Window {
    /**
     * @param title The window title, class, or exe string to match.
     */
    __New(title_matcher, match_mode := 2) {
        this._title_matcher := title_matcher
		this._match_mode := match_mode

		prev_match_mode := A_TitleMatchMode
		SetTitleMatchMode(match_mode)

        ; WinExist returns the unique ID (hWnd) of the first matching window
		this.id := WinExist(title_matcher)
		this._title := ""

        if !this.id {
            ; Optional: You could throw an error or set a flag if window isn't found
            this.id := 0
        }
		else {
			this._title := WinGetTitle(this.id)
		}
		SetTitleMatchMode(prev_match_mode)
    }

	rebind() {
		prev_match_mode := A_TitleMatchMode
		SetTitleMatchMode(this._match_mode)
		Loop {
			WinWait(this._title_matcher,,.5)
			this.id := WinExist(this._title_matcher)
			if this.id
				break
			else
				Sleep(500)
		}
		
		this._title := ""
		this._title := WinGetTitle(this.id)
		this.activate()
		this.wait_active()
		SetTitleMatchMode(prev_match_mode)
	}

	title() {
        if this.id {
            this._title := WinGetTitle(this.id)
			return this._title
		}

	}

	; You can't have a method named class().
	get_class() {
		if this.id
			return WinGetClass(this.id)
	}

	set_title(new_title) {
		if this.id {
			WinSetTitle(new_title, this.id)
			this._title := new_title
		}
	}

    ; Method to bring the window to the front
    activate() {
        if this.id
            WinActivate(this.id)
    }

	is_active() {
		if this.id
			return WinActive(this.id)
	}

	wait_active() {
		if this.id
			WinWaitActive(this.id)
	}

	wait_inactive() {
		if this.id
			WinWaitNotActive(this.id)
	}
    
	minimize() {
        if this.id {
			WinActivate(this.id)
            WinMinimize(this.id)
		}
    }
	
	maximize() {
        if this.id {
            WinMaximize(this.id)
			WinActivate(this.id)
		}
    }

    close() {
        if this.id {
            WinClose(this.id)
			WinWaitClose(this.id)
		}
    }

    move(x := unset, y := unset, w := unset, h := unset) {
        if this.id
            WinMove(x, y, w, h, this.id)
    }

    exists() {
		return WinExist(this.id)
	}

    show() {
        if this.id
            WinShow(this.id)
    }
    
	hide() {
        if this.id
			WinHide(this.id)
    }
} ; class Window

