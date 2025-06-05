ScriptName RYBBoatTokenScript

begin OnDrop Player
    Disable
    PositionCell 0, 0, 0, 0, RYBCell
    ResetInterior RYBCell ; don't think this deletes the reference but I have no other way to do it
    set RYB.TriggerStopDragging to 1
end

begin OnSell Player
    MessageBox "Gasp! How could you sell me? I thought we were friends!"
    set RYB.TriggerStopDragging to 1
end