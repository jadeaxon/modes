#SingleInstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, Icon, %A_ScriptDir%\Icons\Gauntlet.ico
CoordMode, Mouse, Relative

; If you set these too short, the sequences won't trigger in the game.
SetKeyDelay, 40, 40
SetMouseDelay, 40


;==============================================================================
; Functions (Spells)
;==============================================================================

; PRE: Using qwerty keyboard layout when playing Gauntlet.

; For spells with long cooldowns, we launch them immediately when switching to them.
; For spells with short cooldowns, we don't.  You can spam them yourself.

; Switches to chain lightning.
chainLightning() {
	Click Right
	; You can't just use Send {LShift}--does not work in the game.  Needs the down/up.
	Send {LShift down}
	Send {LShift up}
}
	
; Switches to lightning blast.
lightningBlast() {
	Click Right
	Send {Space down}
	Send {Space up}
}

; Activates your lightning shield.
lightningShield() {
	Click Right
	Click Right
	Click Left
}

; Performs an ice blast.
iceBlast() {
	Send {LShift down}
	Send {LShift up}
	Send {Space down}
	Send {Space up}
	Click Left
}

; Launches an ice nova.
iceNova() {
	Send {LShift down}
	Send {LShift up}
	Click Right
	Click Left
}

; Performs a dragon walk to wherever mouse pointer is.
dragonWalk() {
	Send {Space down}
	Send {Space up}
	Send {LShift down}
	Send {LShift up}
	Click Left
}


; Launches a fire grenade.
fireGrenade() {
	Send {Space down}
	Send {Space up}
	Click Right
	Click Left
}


; Dragon walks to wherever mouse is hovering then lightning blasts wherever mouse is.
dragonWalkThenLightningBlast() {
	dragonWalk()
	
	; For duration of dragon walk.
	Sleep 700
	
	lightningBlast()
	Click Left 
}


; Puts up lightning shield then switches to chain lightning.
shieldThenChainLightning() {
	lightningShield()
	chainLightning()
}


; Does an ice blast then switches to chain lightning.
iceBlastThenChainLightning() {
	iceBlast()
	chainLightning()
}


; Does an ice nova then switches to chain lightning.
iceNovaThenChainLightning() {
	iceNova()
	chainLightning()
	
}

; Launches a fire grenade then switches to chain lightning.
fireGrenadeThenChainLightning() {
	fireGrenade()
	chainLightning()
}


;==============================================================================
; Hotkeys
;==============================================================================

; Bottom row keys below wasd movement keys are used for defensive manuevers.

; Maps dragon walk defensive manuever to c key.
$e::
	dragonWalkThenLightningBlast()
return 


; Maps shield defensive manuever to x key.
$x::
	shieldThenChainLightning()
return


; Maps ice blast defensive manuever to z key.
$z::
	iceBlastThenChainLightning()
return


; Maps ice nova manuever to e key.
$c::
	iceNovaThenChainLightning()
return


$q::
	fireGrenadeThenChainLightning()
return


; Remaps left potion key.
$r::
	; Send {q down}
	; Send {q up}
	Send {vk51sc010 down}
	Send {vk51sc010 up}
return




; Remaps right potion key.eq
$v::
	; Send {e down}
	; Send {e up}
	Send {vk45sc012 down}
	Send {vk45sc012 up}
return

; On my XPS 15 laptop.
; 45  012	 	d	27.94	E
; 45  012	 	u	0.14	E              	
; 51  010	 	d	1.08	Q              	
; 51  010	 	u	0.09	Q  






