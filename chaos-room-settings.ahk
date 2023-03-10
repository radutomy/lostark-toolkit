; --------------------------------------------------------------------------------
; BOT SETTINGS
; --------------------------------------------------------------------------------

; sets -40 winHeightOffset
IsKyel := true

; Set this to one of the following:
;   north_vern
;   rohendel
;   yorn
;   feiton
;   punika
farmRegion := "punika"

; Set the farm level, eg: 1, 2, 3, 4
; For Punika, just count, eg: Level 2 sun, is the 7th level, so put 7!
farmLevel := 4

; Your skill rotation, it will do them in order. All skills will double tap.
skills := ["d", "q", "e", "w", "r", "s", "a", "f"]

; How long in seconds to fight before leaving
Random battleDuration, 40, 52

; When to Repair
repairAfterFights := 10

; Set to true and the bot will perform random right click attacks in random directions
; This will also rotate your character around for directional skills
BasicAttacks := false

; The slight delay after a basic attack before performing the next skill
BasicAttackDelay := 25

; Randomly move the mouse around the center, this will rotate your character as it does skills
PerformRandomRotation := true

; The auto-stop hour and minute. eg: 9:50 on EUWest
AutoStopHour := 9
AutoStopMinute := 50

; Default load time before it attempts auto-detection
; Recommended to keep these quite low
LoadInDelay := 3
LoadOutDelay := 3

; How long to wait in seconds before attacking after spawning mobs
Random MobAttackDelay, 5, 8

; Minimum and Maximum skill delay (it randomises between the 2)
; in milliseconds, eg: 300 = 0.3 seconds
MinimumSkillDelay := 400
MaximumSkillDelay := 600

; If you feel your clicks are off by a tad bit you can adjust the
; margins here, for example winHeightOffset -40 works for some.
winHeightOffset := 0
winWidthOffset := 0

; The number of times a pixel colour should be read, which is done every 250ms
; So a value of 300 = 75 seconds of attempting to scan for the colour
PixelScanAttempts := 300

; Colours and positions for the pixel scan
PixelChaosDungeonColour1 := 0xAA872F
PixelChaosDungeonColour2 := 0x16131E
PixelChaosDungeonX1 := 1623
PixelChaosDungeonY1 := 894
PixelChaosDungeonX2 := 455
PixelChaosDungeonY2 := 383
PixelLeaveButton := 0x384A5B
PixelLeaveX := 173
PixelLeaveY := 318

; Enable if you're a ShadowHunter. it will press Z when your meter is ready
ShadowFormEnabled := false
ShadowFormX := 962
ShadowFormY := 1097
ShadowFormColor := 0xB50F78