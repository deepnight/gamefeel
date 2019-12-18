#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Escape::
If held
	return
held := true
SetTimer, OnLongPress, 1000
return

Escape Up::
SetTimer, OnLongPress, Off
held := false
return

OnLongPress:
SetTimer, OnLongPress, Off
TrayTip Title, AHK script terminated!
ExitApp
return

b::
Send {Alt Down}{Tab}{Alt Up}
return

F5::
return
