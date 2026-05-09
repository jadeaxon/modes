#Requires AutoHotkey v2.0
#SingleInstance Force

; <C-A Up/Down> increment/decrement brightness by 1.
^!Up::change_brightness(1)
^!Down::change_brightness(-1)

change_brightness(amount) {
    current := get_brightness()
    brightness := current + amount
    
    if (brightness > 100)
        brightness := 100
    else if (brightness < 0)
        brightness := 0
        
    set_brightness(brightness)
}

get_brightness() {
    for property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
        return property.CurrentBrightness
    return 50 ; fallback
}

set_brightness(brightness) {
    for property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
        property.WmiSetBrightness(0, brightness)
}

