; RYB Stage 41 Chest Position Execution

if (RYB.Resetting == 2)
    RYBChestRef.MoveTo RYBBoatRef
else
    RYBChestRef.MoveTo Player
endif
RYBChestRef.SetPos x, RYB.ChestX
RYBChestRef.SetPos y, RYB.ChestY
RYBChestRef.SetPos z, RYB.ChestZ
RYBChestRef.SetAngle z, RYB.ChestAngle
RYBChestRef.SetAngle x, RYB.BoatPitchAngle
RYBChestRef.SetAngle y, RYB.BoatRollAngle