; RYB Stage 32 Lamp Position Calculation

; yaw
set RYB.TempX to RYB.LampSideOffset * RYB.cos + RYB.LampForwardOffset * RYB.sin
set RYB.TempY to RYB.LampForwardOffset * RYB.cos - RYB.LampSideOffset * RYB.sin
set RYB.TempZ to RYB.LampZOffset
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
set RYB.LampX to RYB.BoatX + RYB.TempX
set RYB.LampY to RYB.BoatY + RYB.TempY
set RYB.LampZ to RYB.BoatZ + RYB.TempZ + RYB.RockZOffset