ScriptName RYBBoatReceiptScript

short DoOnce

begin OnAdd
    if (DoOnce == 0)
        SetItemValue 0
        set RYB.BoatPurchased to 1
        RYBForSaleSignRef.Disable
        RYBBoatMapMarker.Enable
        ShowMap RYBBoatMapMarker 1
        set DoOnce to 1
    endif
end