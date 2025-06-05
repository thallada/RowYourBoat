ScriptName RYBMenuScript

float fQuestDelayTime ; controls script processing rate, see: https://cs.uesp.net/wiki/FQuestDelayTime

; Quest script states
short Initializing

; MessageBox states
short Choice
short ChoosingInit
short ChoosingEnroute
short ChoosingSummon
short ChoosingDrag
short ChoosingOnLand

short ChoosingSettings
short SettingDragMaxPitchAngle
short SettingDragPitchSmoothingFactor

; Triggers
short BoatActivated ; player activating the boat will set this to 1 and this script will handle it
; set after RYB handles player casting the row spell
; 3 to show not on boat messagebox, 4 = show dragging messagebox, 5 = show on land messagebox
short TriggerRowCast

begin GameMode
    if (Initializing == 0)
        Set Initializing to 1
        set fQuestDelayTime to RYB.LowUpdateRate
    endif
    if (RYB.BoatPurchased == 0)
        set fQuestDelayTime to RYB.MediumUpdateRate ; for faster menu responsiveness
    endif

    if (BoatActivated == 1)
        set BoatActivated to 0
        Player.AddSpell RYBRowSpell
        if (RYB.BoatMoving >= 1)
            set ChoosingEnroute to 1
            if (RYB.AutoRowing == 0 && RYB.LockHeading == 0)
                MessageBox "Boat is in motion.", "Auto-row Forward", "Auto-row Backward", "Lock Heading", "Toggle Lamp", "Cancel"
            elseif (RYB.AutoRowing == 0 && RYB.LockHeading == 1)
                MessageBox "Boat is in motion with heading locked.", "Auto-row Forward", "Auto-row Backward", "Unlock Heading", "Toggle Lamp", "Cancel"
            elseif (RYB.AutoRowing == 1 && RYB.LockHeading == 0)
                MessageBox "Auto-rowing forwards", "Stop Auto-rowing", "Auto-row Backward", "Lock Heading", "Toggle Lamp", "Cancel"
            elseif (RYB.AutoRowing == 1 && RYB.LockHeading == 1)
                MessageBox "Auto-rowing forwards with heading locked", "Stop Auto-rowing", "Auto-row Forward", "Unlock Heading", "Toggle Lamp", "Cancel"
            elseif (RYB.AutoRowing == 2 && RYB.LockHeading == 0)
                MessageBox "Auto-rowing backwards", "Stop Auto-rowing", "Auto-row Forward", "Lock Heading", "Toggle Lamp", "Cancel"
            elseif (RYB.AutoRowing == 2 && RYB.LockHeading == 1)
                MessageBox "Auto-rowing backwards with heading locked", "Stop Auto-rowing", "Auto-row Forward", "Unlock Heading", "Toggle Lamp", "Cancel"
            endif
            set Choice to GetButtonPressed
        elseif (RYB.Dragging >= 1)
            set ChoosingDrag to 1
            MessageBox "Boat is being dragged.", "Stop Dragging", "Cancel"
            set Choice to GetButtonPressed
        elseif (RYB.OnLand == 0)
            set ChoosingInit to 1
            MessageBox "Cast Row spell or start auto rowing to start moving.", "Auto-row Forward", "Auto-row Backward", "Get On Boat", "Sit Down", "Toggle Lamp", "Drag Boat", "Settings", "Read Manual", "Cancel"
            set Choice to GetButtonPressed
        else
            set ChoosingOnLand to 1
            MessageBox "Boat is on land. Drag it into the water?", "Drag Boat", "Get On Boat", "Sit Down", "Toggle Lamp", "Settings", "Read Manual", "Cancel"
            set Choice to GetButtonPressed
        endif
    endif

    if (ChoosingInit == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingInit to 0
            set RYB.TriggerAutoRow to 1
        elseif (Choice == 1)
            set ChoosingInit to 0
            set RYB.TriggerAutoRow to 2
        elseif (Choice == 2)
            set ChoosingInit to 0
            set RYB.TriggerGetOnBoat to 1
        elseif (Choice == 3)
            set ChoosingInit to 0
            set RYB.TriggerGetOnBoat to 2
        elseif (Choice == 4)
            set ChoosingInit to 0
            if (RYB.LampOn == 0)
                set RYB.LampOn to 1
            else
                set RYB.LampOn to 0
            endif
        elseif (Choice == 5)
            set ChoosingInit to 0
            set RYB.TriggerStartDragging to 1
        elseif (Choice == 6)
            set ChoosingInit to 0
            set ChoosingSettings to 1
            MessageBox "Settings", "Toggle Rocking", "Toggle Player Weight", "Cancel"
            set Choice to GetButtonPressed
        elseif (Choice == 7)
            set ChoosingInit to 0
            RYBManualRef.Activate Player
        elseif (Choice == 8)
            set ChoosingInit to 0
        endif
    endif

    if (ChoosingEnroute == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingEnroute to 0
            if (RYB.AutoRowing == 0)
                set RYB.AutoRowing to 1
            else
                set RYB.AutoRowing to 0
            endif
        elseif (Choice == 1)
            set ChoosingEnroute to 0
            if (RYB.AutoRowing == 1)
                set RYB.AutoRowing to 2
            elseif (RYB.AutoRowing == 2)
                set RYB.AutoRowing to 1
            endif
        elseif (Choice == 2)
            set ChoosingEnroute to 0
            if (RYB.LockHeading == 0)
                set RYB.LockHeading to 1
                Message "Boat will maintain present heading."
            else
                set RYB.LockHeading to 0
                Message "Boat can now turn."
            endif
        elseif (Choice == 3)
            set ChoosingEnroute to 0
            if (RYB.LampOn == 0)
                set RYB.LampOn to 1
            else
                set RYB.LampOn to 0
            endif
        elseif (Choice == 4)
            set ChoosingEnroute to 0
        endif
    endif

    if (ChoosingSummon == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingSummon to 0
            set RYB.TriggerSummonBoat to 1
        elseif (Choice == 1)
            set ChoosingSummon to 0
            set RYB.TriggerSummonBoat to 2
        elseif (Choice == 2)
            set ChoosingSummon to 0
        endif
    endif

    if (ChoosingDrag == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingDrag to 0
            set RYB.TriggerStopDragging to 1
            Message "You stop dragging the boat."
        elseif (Choice == 1)
            set ChoosingDrag to 0
        endif
    endif

    if (ChoosingOnLand == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingOnLand to 0
            set RYB.TriggerStartDragging to 1
        elseif (Choice == 1)
            set ChoosingOnLand to 0
            set RYB.TriggerGetOnBoat to 1
        elseif (Choice == 2)
            set ChoosingOnLand to 0
            set RYB.TriggerGetOnBoat to 2
        elseif (Choice == 3)
            set ChoosingOnLand to 0
            if (RYB.LampOn == 0)
                set RYB.LampOn to 1
            else
                set RYB.LampOn to 0
            endif
        elseif (Choice == 4)
            set ChoosingOnLand to 0
            set ChoosingSettings to 1
            MessageBox "Settings", "Toggle Rocking", "Toggle Player Weight", "Cancel"
            set Choice to GetButtonPressed
        elseif (Choice == 5)
            set ChoosingOnLand to 0
            RYBManualRef.Activate Player
        elseif (Choice == 6)
            set ChoosingOnLand to 0
        endif
    endif

    if (TriggerRowCast == 3)
        set TriggerRowCast to 0
        MessageBox "You're not on the boat." "Summon Boat" "Place Boat Right Here" "Cancel"
        set Choice to GetButtonPressed
        set ChoosingSummon to 1
    elseif (TriggerRowCast == 4)
        set TriggerRowCast to 0
        set ChoosingDrag to 1
        MessageBox "Boat is being dragged.", "Stop Dragging", "Cancel"
        set Choice to GetButtonPressed
    elseif (TriggerRowCast == 5)
        set TriggerRowCast to 0
        set ChoosingOnLand to 1
        MessageBox "Boat is on land. Drag it into the water?", "Drag Boat", "Get On Boat", "Sit Down", "Toggle Lamp", "Settings", "Cancel"
        set Choice to GetButtonPressed
    endif

    if (ChoosingSettings == 1)
        set Choice to GetButtonPressed
        if (Choice == 0)
            set ChoosingSettings to 0
            if (RYB.RockingEnabled == 0)
                set RYB.RockingEnabled to 1
            else
                set RYB.RockingEnabled to 0
            endif
        elseif (Choice == 1)
            set ChoosingSettings to 0
            if (RYB.PlayerWeightEnabled == 0)
                set RYB.PlayerWeightEnabled to 1
            else
                set RYB.PlayerWeightEnabled to 0
            endif
        elseif (Choice == 2)
            set ChoosingSettings to 0
        endif
    endif
end