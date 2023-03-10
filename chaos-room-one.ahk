#NoEnv
#SingleInstance,Force

; Ensure mouse coords are always fetched via screen size 
; and not relative to the active window
CoordMode Mouse, Screen
CoordMode Pixel, Screen

; Screen: Windowed Mode,
; Resolution: 1920x1080 (16:9)
; HUD Size: 100%

#Include C:\gdrive\src\ahk\chaos-room-settings.ahk

gameWidth := 1920
gameHeight := 1080
winWidth := 0
winHeight := 0
repairFightCount := 0
startTime := 0
firstEnter := true
SetWindowLocation()
InBattle := false
ClassShadowFormUsed := false

; --------------------------------------------------------------------------------
; INITIALIZE KEYS
; --------------------------------------------------------------------------------

F1::
    Log("FarmBot")

    ; reset log file
    LogReset()

    ; Start bot timers
    SetTimer, SkillsLoop, 1000
    SetTimer, BattleLoop, -100
return

F3::
    SetWindowLocation()

    ; Output the current mouse coordinates
    MouseGetPos, MouseX, MouseY

    xpos := MouseX - winWidth
    ypos := MouseY - winHeight

    DetectedColour := GetPixelColor(xpos, ypos)
    PixelGetColor, MouseColour, %MouseX%, %MouseY%, Slow RGB

    Log("Position: " xpos ", " ypos " --- Colour: " DetectedColour "(" MouseColour ")")
return

F5::
    FocusGame()
    Log("Running click test via repair...")
    Repair()
    MsgBox, Repair test complete, press ESCAPE key to close bot
return

F6::
    FocusGame()
    CheckShadowHunterMeterState()
return

Escape::
    Log("Bot duration: " Duration())
    MsgBox Stopped! Duration: %duration%
ExitApp
Return

; --------------------------------------------------------------------------------
; BOT LOGIC
; --------------------------------------------------------------------------------

SkillsLoop:
    ; Only perform skills when we're in battle mode
    if (InBattle) {
        ; Spam skills

        Loop, 8
        {
            if (InBattle) {
                ; Perform a random rotation
                RandomRotation()

                ; Basic Attack
                UseBasicAttack()

                Random, key, 1, 8
                ; Use a skill
                UseSkill(skills[key])

                ; Shadow Hunter specific
                if (ShadowFormEnabled) {
                    CheckShadowHunterMeterState()
                }
            }
        }

        ; for index, keypress in skills
        ; {
        ; 	if (InBattle) {
        ; 		; Perform a random rotation
        ; 		RandomRotation()

        ; 		; Basic Attack
        ; 		UseBasicAttack()

        ; 		; Use a skill
        ; 		UseSkill(keypress)

        ; 		; Shadow Hunter specific
        ; 		if (ShadowFormEnabled) {
        ; 			CheckShadowHunterMeterState()
        ; 		}
        ; 	}
        ; }
    }
return

BattleLoop:
    startTime := Unix()
    InBattle := false

    ; Check if we're at the deadline
    if (CloseToResetTime())
    {
        MsgBox Cannot start the bot this close to the daily reset.
        ExitApp
        Return
    }

    ; Focus game
    FocusGame()
    Sleep, 1000

    ; Logic loop
    Loop,
    {
        ; Check bot deadline
        CheckBotrunTime()

        ; Reset some Settings
        ResetStates()

        ; Open chaos dungeon board
        OpenChaosDungeonWindow()

        ; Wait to load in
        LoadInDetection()

        ; Perform a repair check
        RepairCheck()

        ; Move forward a smidge by clicking in center of the screen
        SpawnMonsters()

        ; Wait after spawning mobs
        Sleep, MobAttackDelay * 1000

        ; Enable battle mode
        InBattle := true

        ; Wait in battle
        Log("> Battle Duration: " battleDuration " seconds...")
        Sleep, (battleDuration-1) * 1000

        ; Stop fighting
        InBattle := false
        Sleep, 200

        ; Leave
        Log("> Leaving Chaos Dungeon!")
        ClickPosition(139, 320)
        Sleep, 600
        Send, {enter}

        ; Load out screen
        Sleep, LoadOutDelay * 1000
    }

return

; --------------------------------------------------------------------------------
; CUSTOM FUNCTIONS
; --------------------------------------------------------------------------------

ResetStates() {
    global

    ClassShadowFormUsed := false
}

Log(text) {
    global

    FormatTime, CurrentDateTime,, dd-MM-yy HH:mm:ss
    FileAppend, [%CurrentDateTime%] %text% `n, ./log.txt
}

LogReset() {
    FileDelete, ./log.txt
}

Unix() {
    unix -= 19700101000000, S
return unix
}

Duration() {
    global

    ; Calculate bot duration
    finishTime := Unix()
    duration := finishTime - startTime
    duration := FormatDuration(duration)
}

FormatDuration(s) {
    w = day.hour.minute.second

    loop parse, w, .
        s -= (t := s // (x := 60 ** (e := 4 - a_index) - 129600 * (e = 3))) * x
    , t ? m .= t . " " . a_loopfield . chr(115 * (t != 1)) . chr(32 * !!e)

return m ? m : "0 seconds"
}

CheckBotrunTime() {
    global

    ; Check if the deadline has reached
    if (CloseToResetTime())
    {
        Log("--- Automatically stopping bot as its close to the daily reset time.")
        Log("--- Bot duration: " Duration())

        ; Leave
        ClickPosition(139, 320)
        Sleep, 1000
        Send, {enter}

        MsgBox Bot Auto-Stopped! Duration: %duration%
        ExitApp
        Return
    }
}

CloseToResetTime() {
    global

    FormatTime, CurrentMinutes,, m
    FormatTime, CurrentHours,, H

    ; We are at 9am and we're at minutes 50-59
    if (CurrentHours == AutoStopHour && CurrentMinutes >= AutoStopMinute) {
        return true
    }

    ; We're at 9am but not minutes 50-59
return false
}

FocusGame() {
    WinActivate, ahk_exe GeForceNOW.exe
}

SetWindowLocation() {
    global

    ; Get the Window Position
    WinGetPos, winWidth, winHeight,,, A

    winHeight := winHeight + winHeightOffset
    winWidth := winWidth + winWidthOffset

    ; specific for kyel
    if (IsKyel) {
        winHeight := winHeight - 40
    }
}

ClickCenter() {
    global

    ClickPosition((gameWidth / 2), (gameHeight / 2))
}

ClickPosition(x, y) {
    global

    SetWindowLocation()

    ; Add window position to the clicks
    width := winWidth + x
    height := winHeight + y

    ; Log(">> Click Position: " width " / " height)

    Sleep, 500
    Send {Click %width% %height%}
}

RightClickPosition(x, y) {
    global

    SetWindowLocation()

    ; Add window position to the clicks
    width := winWidth + x
    height := winHeight + y

    ; Log(">> RightClick Position: " width " / " height)

    Sleep, 200
    Send {Click %width% %height% Right}
}

MoveMouse(x, y) {
    global

    SetWindowLocation()

    ; Add window position to the clicks
    width := winWidth + x
    height := winHeight + y

    ; Move the mouse into position
    MouseMove, width, height, 0
}

GetPixelColor(x, y) {
    global

    SetWindowLocation()

    ; negate 10 because of game cursor 
    width := x + winWidth
    height := y + winHeight

    PixelGetColor, DetectedColour, width, height, Slow RGB
return DetectedColour
}

GetPixelSearch(x, y, colour, accuracy) {
    global

    SetWindowLocation()

    ; negate 10 because of game cursor 
    width := x + winWidth
    height := y + winHeight

    PixelSearch, OutputVarX, OutputVarY, width-10, height-10, width+10, height+10, colour, accuracy, Fast RGB

    ;; Log(colour " = " OutputVarX)

return OutputVarX
}

RepairCheck() {
    global

    ; Repair
    repairFightCount++
    if (repairFightCount >= repairAfterFights) 
    {
        Log("Performing gear repair...")
        repairFightCount := 0
        Repair()
        Sleep, 1000
    }
}

Repair() {
    global

    Log("Performing Repair...")

    ClickPosition(1743, 1078)
    ClickPosition(1742, 857)
    ClickPosition(1255, 725)
    ClickPosition(1086, 462)
    ClickPosition(1794, 1061)
    ClickPosition(1383, 248)

    Log("Repair Complete!")
}

SelectFarmRegion() {
    global

    Log("Selecting Farm Region: " farmRegion)

    ; north_vern
    ; rohendel
    ; yorn
    ; feiton
    ; punika
    switch farmRegion {
    case "north_vern":
        ClickPosition(358, 262)
    return

case "rohendel":
    ClickPosition(615, 261)
return 

case "yorn":
    ClickPosition(832, 263)
return

case "feiton":
    ClickPosition(1099, 272)
return

case "punika":
    ClickPosition(1342, 260)
return
}
}

SelectFarmLevel() {
    global

    Log("Selecting Farm Level: " farmLevel)

    switch farmLevel {
    case 1:
        ClickPosition(415, 388)
    return

case 2:
    ClickPosition(418, 462)
return 

case 3:
    ClickPosition(418, 525)
return

case 4:
    ClickPosition(410, 597)
return

case 5:
    ClickPosition(410, 664)
return

case 6:
    ClickPosition(410, 742)
return

case 7:
    ClickPosition(410, 809)
return

case 8:
    ClickPosition(410, 883)
return
}
}

UseSkill(key) {
    global 

    if (!InBattle) {
        return
    }

    Random, skillDelay, MinimumSkillDelay, MaximumSkillDelay

    ; fire off the skill
    ; Log(">> Skill: " key)
    Send, {%key%}
    Random skillDel, 20, 80
    Sleep, skillDel
    Send, {%key%}
    Random skillDel, 20, 80
    Sleep, skillDel
    Send, {%key%}

    ; Delay after the skill
    Sleep, skillDelay
}

UseBasicAttack() {
    global 

    if (!BasicAttacks || !InBattle) {
        return
    }

    Sleep, BasicAttackDelay

    gameWidthCenter := (gameWidth / 2)
    gameHeightCenter := (gameHeight / 2)

    Random, gameWidthCenterRandom, -100, 100
    Random, gameHeightCenterRandom, -100, 100

    gameWidthCenter := gameWidthCenter + gameWidthCenterRandom
    gameHeightCenter := gameHeightCenter + gameHeightCenterRandom

    ; Log(">> Basic Attack: " gameWidthCenter " / " gameHeightCenter)

    RightClickPosition(gameWidthCenter, gameHeightCenter)
}

SpawnMonsters() {
    Log("Moving to spawn mobs")
    ClickCenter()
}

RandomRotation() {
    global

    if (!PerformRandomRotation || !InBattle) {
        return
    }

    gameWidthCenter := (gameWidth / 2)
    gameHeightCenter := (gameHeight / 2)

    Random, gameWidthCenterRandom, -100, 100
    Random, gameHeightCenterRandom, -100, 100

    gameWidthCenter := gameWidthCenter + gameWidthCenterRandom
    gameHeightCenter := gameHeightCenter + gameHeightCenterRandom

    ; Log(">> MoveMouse: " gameWidthCenter " / " gameHeightCenter)

    MoveMouse(gameWidthCenter, gameHeightCenter)
}

LoadInDetection() {
    global

    Log("Loading in, waiting " LoadInDelay " seconds before starting auto-detection...")
    Sleep LoadInDelay * 1000

    attempts := 0
    while (attempts < PixelScanAttempts) {
        attempts++
        Sleep, 500

        ; Move mouse into the correct position as we need the "hover" state
        MoveMouse(PixelLeaveX, PixelLeaveY)

        ; Read colour of the leave button
        DetectedColour := GetPixelSearch(PixelLeaveX, PixelLeaveY, PixelLeaveButton, 8)

        if (DetectedColour > 0) {
            attempts := 0
            Log("Chaos Dungeon Start Zone Detected!")
            break
        }
    }

    if (attempts >= PixelScanAttempts) {
        Log("Could not detect entering Chaos Dungeon after " attempts " attempts...")
        MsgBox Failed to get into Chaos Dungeon Window! Exiting Bot...
        ExitApp
        Return
    }
}

OpenChaosDungeonWindow() {
    global

    Log("Opening the Chaos Dungeon Window...")

    ; Keep looping until it opens (delay for 1 second)
    attempts := 0
    while (attempts < PixelScanAttempts) {
        attempts++

        ; Move mouse into the correct position as we need the "hover" state
        MoveMouse(PixelChaosDungeonX1, PixelChaosDungeonY1)

        ; Attempt to open
        Send, {g}
        Sleep, 500

        ; 1622, 894
        DetectedColour1 := GetPixelSearch(PixelChaosDungeonX1, PixelChaosDungeonY1, PixelChaosDungeonColour1, 8)
        ; DetectedColour2 := GetPixelSearch(PixelChaosDungeonX2, PixelChaosDungeonY2, PixelChaosDungeonColour2)

        ; Log(DetectedColour1 " , " DetectedColour2)

        if (DetectedColour1 > 0) {
            attempts := 0
            Log("Chaos Dungeon UI Detected!")
            break
        }
    }

    ; If we hit the max attempts
    if (attempts >= PixelScanAttempts) {
        Log("Could not detect the Chaos Dungeon window after " attempts " attempts...")
        MsgBox Failed to open Chaos Dungeon Window! Exiting Bot...
        ExitApp
        Return
    }

    ; Load the correct farming region and level on the initial load
    if (firstEnter) {
        firstEnter := false
        SelectFarmRegion()
        SelectFarmLevel()
    }

    ; Enter 
    Log("Entering...")
    ClickPosition(1545, 896)
    Sleep, 1000
    Send, {enter}
}

CheckShadowHunterMeterState() {
    global 

    if (ClassShadowFormUsed) {
        return
    }

    DetectedColour := GetPixelSearch(ShadowFormX, ShadowFormY, ShadowFormColor, 4)

    if (DetectedColour) {
        Log("In shadow form!")
        Send, {z}
        ClassShadowFormUsed := true
        Sleep, 500
    }
}