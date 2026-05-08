#Requires AutoHotkey v2.0

; A String class that works more like Python strings.
class StringPlus {
	; constructor
    __New(value) {
        this.value := String(value)
    }

    ; This allows the object to be used in string math/concatenation
    ; e.g., msg := "Result: " . myWrapper
    ToString() => this.value

	; WARNING: There is no way to have AHK magically always autoconvert to a normal string.
	; So, you have to do things like MsgBox(sp.str()).
	; Shorter version of ToString().
	str() => this.value

    ; [] but with 0-based indexes. Also handles negative indexes.
	; You can do s[0] := "whatever" -- you aren't limited to replacing a single character
	__Item[s, l := 1] {
        get {
            ; Convert 0-based/negative to AHK 1-based
            pos := (s < 0) ? s : s + 1
            return SubStr(this.value, pos, l)
        }
        set {
            ; 1. Calculate actual 1-based start position
            ; If s is -1, it's the last char. If s is 0, it's the first.
            startPos := (s < 0) ? (StrLen(this.value) + s + 1) : (s + 1)
            
            ; 2. Slice the string
            left := SubStr(this.value, 1, startPos - 1)
            right := SubStr(this.value, startPos + l)
            
            this.value := left . value . right
        }
    }

	; Length.
    len() => StrLen(this.value)

    ; Useful to call when you get a string from the clipboard.
    exorcise() {
        this.value := Trim(this.value, ' "')
        this.value := RTrim(this.value, "`r`n")
        return this
    }

	/**
     * @param needle - The string to look for
     * @param caseSense - "On" (default), "Off", or "Locale"
     */
    startswith(needle, caseSense := "On") {
        len := StrLen(needle)
        return StrCompare(SubStr(this.value, 1, len), needle, caseSense) = 0
    }

    /**
     * @param needle - The string to look for
     * @param caseSense - "On" (default), "Off", or "Locale"
     */
    endswith(needle, caseSense := "On") {
        len := StrLen(needle)
        ; Use negative offset in SubStr to start from the end
        return StrCompare(SubStr(this.value, -len), needle, caseSense) = 0
    }

	/**
     * Split string by delimiter. 
     * If delimiter is "", it splits by any whitespace (Python behavior).
     * @param delimiter - The string to split by.
     * @param maxsplit - Maximum number of splits to perform. -1 is no limit.
     */
    split(delimiter := "", maxsplit := -1) {
        result := []
        
        ; Case 1: Python-style whitespace split
        if (delimiter == "") {
            ; RegEx matches one or more whitespace characters
            regex := "\s+"
            
            ; We use a loop to respect maxsplit
            remaining := this.value
            count := 0
            
            while (maxsplit == -1 || count < maxsplit) {
                if RegExMatch(remaining, regex, &match) {
                    pos := match.Pos
                    len := match.Len
                    
                    ; Add the part before the whitespace (if not empty)
                    part := SubStr(remaining, 1, pos - 1)
                    if (part != "")
                        result.Push(part)
                    
                    remaining := SubStr(remaining, pos + len)
                    count++
                } else {
                    break
                }
            }
            if (remaining != "")
                result.Push(remaining)
                
        } else {
            ; Case 2: Literal delimiter split
            result := StrSplit(this.value, delimiter,, maxsplit + 1)
        }
        
        return result
    } ; split()

	/**
     * Python-style string repetition.
	 * You can't overload * in AHK, but we can have a repeat() method.
     * @param count - Number of times to repeat
     */
    repeat(count) {
        if (count <= 0)
            return StringPlus("")
            
        result := ""
        Loop count {
            result .= this.value
        }
        return StringPlus(result)
    }

	/**
     * Python-style strip.
     * @param chars - The characters to remove (defaults to whitespace)
     */
    strip(chars := " `t`r`n") {
        ; Trim() in AHK v2 handles the work
        return StringPlus(Trim(this.value, chars))
    }

    lstrip(chars := " `t`r`n") => StringPlus(LTrim(this.value, chars))
    rstrip(chars := " `t`r`n") => StringPlus(RTrim(this.value, chars))
	
	upper() => StringPlus(StrUpper(this.value))
    lower() => StringPlus(StrLower(this.value))
    title() => StringPlus(StrTitle(this.value))

	removeprefix(prefix) {
        if this.startswith(prefix)
            return StringPlus(SubStr(this.value, StrLen(prefix) + 1))
        return StringPlus(this.value)
    }

    removesuffix(suffix) {
        if this.endswith(suffix)
            return StringPlus(SubStr(this.value, 1, -StrLen(suffix)))
        return StringPlus(this.value)
    }

	replace(old, new, limit := -1) {
        return StringPlus(StrReplace(this.value, old, new, , limit))
    }

    find(sub, start := 1) {
        pos := InStr(this.value, sub, , start)
        return (pos - 1)
    }



} ; class StringPlus
