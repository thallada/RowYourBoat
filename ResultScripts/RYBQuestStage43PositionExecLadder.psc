; RYB Stage 43 Ladder Position Execution

if (RYB.Resetting == 2)
    RYBLadderRef.MoveTo RYBBoatRef
else
    RYBLadderRef.MoveTo Player
endif
RYBLadderRef.SetPos x, RYB.LadderX
RYBLadderRef.SetPos y, RYB.LadderY
RYBLadderRef.SetPos z, RYB.LadderZ
RYBLadderRef.SetAngle z, RYB.BoatAngle
RYBLadderRef.SetAngle x, RYB.BoatPitchAngle
RYBLadderRef.SetAngle y, RYB.BoatRollAngle 