ScriptName RYBChestReceiptScript

short DoOnce

begin OnAdd
    if (DoOnce == 0)
        SetItemValue 0
        set RYB.ChestPurchased to 1
        RYBChestRef.Enable
        set RYB.Resetting to 2 ; trigger one-time boat position reset to make sure the chest is placed on the boat
        set DoOnce to 1
    endif
end