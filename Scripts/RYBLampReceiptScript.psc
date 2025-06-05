ScriptName RYBLampReceiptScript

short DoOnce

begin OnAdd
    if (DoOnce == 0)
        SetItemValue 0
        set RYB.LampPurchased to 1
        RYBLampOffRef.Enable
        set RYB.Resetting to 2 ; trigger one-time boat position reset to make sure the lamp is placed on the boat
        set DoOnce to 1
    endif
end