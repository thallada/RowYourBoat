; RYB Stage 40 Seat Position Execution

if (RYB.Resetting == 2)
    RYBSeatRef.MoveTo RYBBoatRef
else
    RYBSeatRef.MoveTo Player
endif
RYBSeatRef.SetPos x, RYB.SeatX
RYBSeatRef.SetPos y, RYB.SeatY
RYBSeatRef.SetPos z, RYB.SeatZ
RYBSeatRef.SetAngle z, RYB.BoatAngle
RYBSeatRef.SetAngle x, RYB.BoatPitchAngle
RYBSeatRef.SetAngle y, RYB.BoatRollAngle 