ScriptName RYBLadderReceiptScript

short DoOnce

begin OnAdd
    if (DoOnce == 0)
        SetItemValue 0
        set RYB.LadderPurchased to 1
        set RYB.Resetting to 2 ; trigger one-time boat position reset to make sure the ladder is placed on the boat
        set DoOnce to 1
    endif
end