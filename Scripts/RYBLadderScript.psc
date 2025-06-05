ScriptName RYBLadderScript

begin OnActivate
    if (RYB.BoatMoving >= 1)
        set RYB.TriggerGetOnBoat to 1
    else ; can only use the seat if the boat is not moving
        set RYB.TriggerGetOnBoat to 2
    endif
end