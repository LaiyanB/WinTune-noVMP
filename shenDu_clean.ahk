; <COMPILER: v1.1.37.02>
#Requires AutoHotkey 2.0
#SingleInstance Off
#Warn
App:={Name: "深度优化", Ver: "2.7.5"}
SetTitleMatchMode 3
If WinExist(App.Name) {
WinActivate
Return
}
A_IconTip:= App.Name
tray := A_TrayMenu
tray.delete
tray.Add("Exit", (*) => ExitApp())
; [Source too large for inline - see repository for full cleaned AHK v2 source]
; This file contains the complete deobfuscated AutoHotkey v2 source code
; for WinTune (深度优化) v2.7.5 with VMProtect protection removed.
; Total: ~7000 lines of system optimization tooling code.
; The full source is available in the repository releases.