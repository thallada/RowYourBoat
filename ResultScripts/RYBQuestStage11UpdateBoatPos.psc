; RYB Quest Stage 11 Update Boat Position and Angle

set RYB.BoatX to RYBBoatRef.GetPos x
set RYB.BoatY to RYBBoatRef.GetPos y
set RYB.BoatZ to RYBBoatRef.GetPos z
set RYB.BoatZ to RYB.BoatZ - RYB.RockZOffset ; remove rocking offset from last frame to get "true" Z
set RYB.BoatAngle to RYBBoatRef.GetAngle z
set RYB.BoatAngle to RYB.BoatAngle - 90
if (RYB.BoatAngle < 0)
    set RYB.BoatAngle to RYB.BoatAngle + 360
elseif (RYB.BoatAngle >= 360)
    set RYB.BoatAngle to RYB.BoatAngle - 360
endif