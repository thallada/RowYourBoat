; RYB Stage 31 Chest Position Calculation

; yaw
set RYB.TempX to RYB.ChestSideOffset * RYB.cos + RYB.ChestForwardOffset * RYB.sin
set RYB.TempY to RYB.ChestForwardOffset * RYB.cos - RYB.ChestSideOffset * RYB.sin
set RYB.TempZ to RYB.ChestZOffset
; roll
set RYB.OrigX to RYB.TempX
set RYB.OrigZ to RYB.TempZ
set RYB.TempX to RYB.OrigX * RYB.CosRoll - RYB.OrigZ * RYB.SinRoll
set RYB.TempZ to RYB.OrigX * RYB.SinRoll + RYB.OrigZ * RYB.CosRoll
; pitch
set RYB.OrigY to RYB.TempY
set RYB.OrigZ to RYB.TempZ
set RYB.TempY to RYB.OrigY * RYB.CosPitch + RYB.OrigZ * RYB.SinPitch
set RYB.TempZ to -RYB.OrigY * RYB.SinPitch + RYB.OrigZ * RYB.CosPitch
; to world coords
set RYB.ChestX to RYB.BoatX + RYB.TempX
set RYB.ChestY to RYB.BoatY + RYB.TempY
set RYB.ChestZ to RYB.BoatZ + RYB.TempZ + RYB.RockZOffset
set RYB.ChestAngle to RYB.BoatAngle - RYB.ChestAngleOffset
if (RYB.ChestAngle < 0)
    set RYB.ChestAngle to RYB.ChestAngle + 360
elseif (RYB.ChestAngle >= 360)
    set RYB.ChestAngle to RYB.ChestAngle - 360
endif