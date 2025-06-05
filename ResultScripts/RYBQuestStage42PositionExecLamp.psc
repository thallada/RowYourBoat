; RYB Stage 42 Lamp Position Execution

if (RYB.Resetting == 2)
    RYBLampOffRef.MoveTo RYBBoatRef
else
    RYBLampOffRef.MoveTo Player
endif
RYBLampOffRef.SetPos x, RYB.LampX
RYBLampOffRef.SetPos y, RYB.LampY
RYBLampOffRef.SetPos z, RYB.LampZ
RYBLampOffRef.SetAngle z, RYB.BoatAngle
RYBLampOffRef.SetAngle x, RYB.BoatPitchAngle
RYBLampOffRef.SetAngle y, RYB.BoatRollAngle 
if (RYB.LampOn == 1)
    if (RYB.Resetting == 2)
        RYBLampOnRef.MoveTo RYBBoatRef
    else
        RYBLampOnRef.MoveTo Player
    endif
    RYBLampOnRef.SetPos x, RYB.LampX
    RYBLampOnRef.SetPos y, RYB.LampY
    RYBLampOnRef.SetPos z, RYB.LampZ
    RYBLampOnRef.SetAngle z, RYB.BoatAngle
    RYBLampOnRef.SetAngle x, RYB.BoatPitchAngle
    RYBLampOnRef.SetAngle y, RYB.BoatRollAngle
endif