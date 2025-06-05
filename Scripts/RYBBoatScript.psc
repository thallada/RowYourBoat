ScriptName RYBBoatScript

begin OnActivate
    if (RYB.BoatPurchased == 0)
        MessageBox "There's a note attached to the rowboat that reads: 'Contact Sergius Verus at the Three Brothers Trade Goods in the Market District to purchase this boat.'" "Ok"
    else
        set RYBMenu.BoatActivated to 1
    endif
end