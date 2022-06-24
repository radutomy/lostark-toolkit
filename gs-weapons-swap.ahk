; Put this file in: C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
; Or type in shell:startup in Run

SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% 
#SingleInstance, force
#NoTrayIcon
#NoEnv

XPos :=0
YPos :=0

; loop all available screens
SysGet, MCount, MonitorCount

Loop, %MCount%
{
    ; get screen resolution of all monitors
    SysGet, M, Monitor, %A_Index%

    if (MRight == 1920)
    {
        XPos := 957
        YPos := 980 ; 105% HUD
        ; YPos := 974 ; 100% HUD
    }
    else if (MRight == 2560)
    {
        XPos := 1277
        YPos := 1322 ; 90% HUD
        ; YPos := 1308 ; 100% HUD
    }
}

#If WinActive("ahk_exe LOSTARK.exe") OR WinActive("ahk_exe GeForceNOW.exe")

1::
    PixelGetColor, color, XPos, YPos, rgb
    vred := ((color & 0xFF0000) >> 16)
    vgreen := ((color & 0xFF00) >> 8)
    vblue := (color & 0xFF)

    ; pistol - 0xFF9A02
    if (vred > 150 and vblue < 50) {

    }
    ; shotgun - 0x029AFF
    else if (vred < 50 and vblue > 200) {
        Send, {XButton2}
    }
    ; rifle - 0xF000FF
    else if (vred > 150 and vblue > 100) {
        Send, {XButton1}
    }
return

2::
    PixelGetColor, color, XPos, YPos, rgb
    vred := ((color & 0xFF0000) >> 16)
    vgreen := ((color & 0xFF00) >> 8)
    vblue := (color & 0xFF)

    ; pistol - 0xFF9A02
    if (vred > 150 and vblue < 50)
    {
        Send, {XButton1}
    }
    ; shotgun - 0x029AFF
    else if (vred < 50 and vblue > 200) {

    }
    ; rifle - 0xF000FF
    else if (vred > 150 and vblue > 100)
    {
        Send, {XButton2}
    }
return

3::
    PixelGetColor, color, XPos, YPos, rgb
    vred := ((color & 0xFF0000) >> 16)
    vgreen := ((color & 0xFF00) >> 8)
    vblue := (color & 0xFF)

    ; pistol - 0xFF9A02
    if (vred > 150 and vblue < 50)
    {
        Send, {XButton2}
    }
    ; shotgun - 0x029AFF
    else if (vred < 50 and vblue > 200)
    {
        Send, {XButton1}
    }
    ; rifle - 0xF000FF
    else if (vred > 150 and vblue > 100) {

    }
return
