; RYB Stage 33 Ladder Position Calculation

; yaw
set RYB.TempX to RYB.LadderSideOffset * RYB.cos + RYB.LadderForwardOffset * RYB.sin
set RYB.TempY to RYB.LadderForwardOffset * RYB.cos - RYB.LadderSideOffset * RYB.sin
set RYB.TempZ to RYB.LadderZOffset
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
set RYB.LadderX to RYB.BoatX + RYB.TempX
set RYB.LadderY to RYB.BoatY + RYB.TempY
set RYB.LadderZ to RYB.BoatZ + RYB.TempZ + RYB.RockZOffset