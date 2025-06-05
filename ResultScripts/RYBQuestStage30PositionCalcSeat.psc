; RYB Stage 30 Seat Position Calculation

; yaw
set RYB.TempX to RYB.SeatSideOffset * RYB.cos + RYB.SeatForwardOffset * RYB.sin
set RYB.TempY to RYB.SeatForwardOffset * RYB.cos - RYB.SeatSideOffset * RYB.sin
set RYB.TempZ to RYB.SeatZOffset
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
set RYB.SeatX to RYB.BoatX + RYB.TempX
set RYB.SeatY to RYB.BoatY + RYB.TempY
set RYB.SeatZ to RYB.BoatZ + RYB.TempZ + RYB.RockZOffset