ScriptName RYBRowSpellScript

begin ScriptEffectStart
    if (Player.IsSneaking)
        set RYB.TriggerRowCast to 2
    else
        set RYB.TriggerRowCast to 1
    endif
end