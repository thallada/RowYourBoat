; RYB Stage 51 Enable Boat and Attachment Refs

RYBBoatRef.Enable
RYBBoatMapMarker.Enable
RYBSeatRef.Enable
if (RYB.ChestPurchased == 1)
    RYBChestRef.Enable
endif
if (RYB.LampPurchased == 1)
    if (RYB.LampOn == 1)
        RYBLampOnRef.Enable
    endif
    RYBLampOffRef.Enable
endif
if (RYB.LadderPurchased == 1 && RYB.LadderDeployed == 1)
    RYBLadderRef.Enable
endif